# NNUE NEON復旧（2026-09-27）

## 原因と修正

対象はclassic NNUEの`source/eval/nnue/layers/affine_transform_sparse_input.h`。
`USE_NEON=8`だけでも`GetWeightIndex()`が`GetWeightIndexScrambled()`を選び、512→32層の重みを4入力単位のブロック配置へ並べ替えていた。
しかし`Propagate()`のARM側ブロック積和カーネルは`USE_NEON_DOTPROD`でしか有効にならない。
通常NEONでは`affine_transform_unaligned()`へ進み、`weights[row * stride + column]`の通常行優先配置として読むため、別の重みを掛けていた。

4か所の`defined(USE_SSSE3) || USE_NEON >= 8`を`defined(USE_SSSE3) || defined(USE_NEON_DOTPROD)`へ揃えた。
対象は非ゼロ入力探索補助、kChunkSize、GetWeightIndex、Propagateの外側ガード。
通常NEONは行優先ロード＋NEON dense積和、DOTPRODはscrambleロード＋DOTPROD block積和となる。
通常`AffineTransform`は既にSSSE3/DOTPRODの条件が一致しており変更していない。
feature transformerはHalfKPの16bit重みを通常順でロードして加減算する別段であり、本修正によるレイアウト変更はない。
forwardはfeature transformer→512/32 sparse affine→ReLU→32/32 affine→ReLU→32/1 affine→FV_SCALE除算。

nn.binそのものは破損していない。ロード成功後の内部配列配置の誤りである。
`readyok`とファイルSHA一致は演算の正しさを保証しない。

## ビルド

既存の`Android.mk`は変更しない：ARMv8-A、USE_NEON=8、DOTPRODなし、HASH_KEY_BITS=128、TT_CLUSTER_SIZE=4、Ofast/LTO、pthread、release。
DOTPRODを外す追加変更や最適化の引下げ、探索時間の増加は行っていない。
上流基点は`c1b80eaa09fe13d5f12b1599d1ae4d53c224de30`。本修正は追加パッチとして記録する。

採用バイナリ：1162064 bytes、SHA-256 `28647dbf16571809dc4713950bd121b87c28b33436516ee2976a14f13d5dc6e7`。
NNUE：64217066 bytes、SHA-256 `1141d275bceec911156801f27303dc9ff5beb24f4f59144cc069306c59e80782`、FV_SCALE=20。

## 検証

- 実機：Pixel 9a。Flutter・Teacherを経由せずADBから起動。
- 数値テスト：16入力組×32出力。未修正512/512不一致、修正NEON 0/512不一致、DOTPROD 0/512不一致。
- 99局面：旧DOTPRODと修正NEONの生評価値は全件完全一致。未修正NEONは全件不一致。
- 履歴付きpositionと直接SFENの評価値も確認。
- 20局面、Threads=1、Hash=256MB、MultiPV=1、no_book、各局面前isreadyでTT/historyを初期化、go nodes 200000：bestmove/score/PV/ノード数は旧DOTPRODと修正NEONで全件一致。
- 2局面だけ最後に表示されるdepthが1異なる。同じノード数・score・PVで、停止とPvIntervalの出力タイミング差。評価値差ではない。
- 12秒、Threads=4、Hash=256MB、初期局面：未修正NEON 最終depth4/21,075,552nodes/1,756,003nps、旧DOTPROD depth34/33,388,660nodes/2,782,388nps、修正NEON 最終採用depth33/21,556,140nodes/1,796,195nps（探索中表示最大35）。
- 3種類の20局面bestmove/PVは合法性確認済み。

全局面・全ネットワークに対する形式証明ではないが、配置条件の修正、スカラー基準、実NNUEの局面一致、同一探索の一致を組み合わせて確認した。
テスト`tests/nnue_layout_test.cpp`は今回の壊れたヘッダーでは失敗する。
実行：`tools/test_nnue_layout.ps1`。DOTPROD対応端末では`-Dotprod`も実行可能。

## 配布方針

当面は修正NEON版1本を採用する。ARM64/NEON端末でDOTPRODを要求しない。
旧DOTPROD版はPixel 9aで正常かつ高速だが、それだけを全ARM64へ無条件配布しない。
将来の2本配布では、ABIでなく実CPU機能で判定し、同一ソース/同一評価関数で両方を回帰検証する。

V6のstop-drain、ログ、局面同期ガードは別の安全策であり維持。Teacher/CPUの共有停止境界の改善は別タスクとする。
