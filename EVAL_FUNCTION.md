# 搭載評価関数（2026-11-02）

アプリが読む評価関数は、つようら王11micro。アーキテクチャは `SFNN_ka2_2048_8_64_progress8`。`nn.bin` と `progress.bin` を同じ EvalDir に置く。`FV_SCALE` は 24。作者は nn.bin と progress.bin を MIT License としている。Android ビルドは `YANEURAOU_ENGINE_NNUE` に加え `SFNNwoPSQT` と `NNUE_ARCHITECTURE_HEADER=architectures/SFNN_ka2_2048_8_64_progress8.h`。

| ファイル | サイズ | SHA-256 |
| --- | --- | --- |
| nn.bin | 3864610 | `7f9545dbf73b87acf312146daabf59c4f17d0845c87d587fa19caed51707dddb` |
| progress.bin | 1003104 | `a2d18f0564639c945b5d6469e9b437cd64a526ad4fbcef02ab1d8f547d08e5f1` |
| libyaneuraou.so | 1169968 | `7fde5bfe072e2f64de2109e275c641a80616de7540b200418d053a17915c5031` |

以下は、それ以前に搭載していた Háo の照合記録。

# 搭載評価関数の配布物照合（2026-10-03）

[作者の公式リリース](https://github.com/nodchip/tanuki-/releases/tag/tanuki-.halfkp_256x2-32-32.2023-05-08)のアーカイブを取得し、実ファイルを確認した。

- 名称: Háo、標準HalfKP 256x2-32-32、2023-05-08版。
- アーカイブ: tanuki-.halfkp_256x2-32-32.2023-05-08.7z、23,966,109 bytes。
- アーカイブSHA-256: `f16dc66c529857bf08fce8cee4f1e53a6993297644100267a6ccccd62e43dbba`。
- 内容: eval/nn.bin と gpl-3.0.txt。
- nn.bin: 64,217,066 bytes、`1141d275bceec911156801f27303dc9ff5beb24f4f59144cc069306c59e80782`。アプリ搭載物と完全一致。
- GPL文書SHA-256: `230184f60bae2feaf244f10a8bac053c8ff33a183bcc365b4d8b876d2b7f4809`。アプリのassets/licenses/GPL-3.0.txtと完全一致。
- 作者はFV_SCALE=20を推奨している。実装の設定値も20。

旧EVAL_FUNCTION.mdの「公式配布物未確認」は解消した。この照合は公式配布物・同梱文書の確認記録であり、アプリ全体の配布方式に関する法的判断ではない。評価関数を公開GPLリポジトリへ追加する操作は実施していない。

## 従来の記録

# 評価関数

Public リポジトリには `nn.bin` を置いていない。再配布できるとは判断していない。

| 項目 | 記録 |
| --- | --- |
| 名称 | Háo（tanuki- halfkp_256x2-32-32。旧開発メモ上の呼称） |
| ファイル名 | `nn.bin` |
| サイズ | 64217066 bytes |
| SHA-256 | `1141d275bceec911156801f27303dc9ff5beb24f4f59144cc069306c59e80782` |
| 入手元として旧開発メモが示す場所 | https://github.com/nodchip/tanuki-/releases/tag/tanuki-.halfkp_256x2-32-32.2023-05-08 |
| 旧開発メモが示すアーカイブ | `tanuki-.halfkp_256x2-32-32.2023-05-08.7z` |
| エンジン側の設定 | `FV_SCALE=20`、`EvalDir` 配下の `nn.bin` |
| ライセンス確認 | 未了 |

旧開発メモは、リリースアーカイブに `gpl-3.0.txt` が同梱されていることを再配布の根拠にしている。この Phase ではそのアーカイブを取り直して中身を確認していない。そのため、再配布可能とは書かない。確認が終わるまで、このファイルは公開リポジトリへ追加しない。
