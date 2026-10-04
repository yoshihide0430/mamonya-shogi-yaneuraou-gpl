# 対応ソース

やねうら王の対応ソースは `third_party/YaneuraOu` に置いてある。ビルドスクリプトは上流GitHubから取得しない。

| 項目 | 値 |
| --- | --- |
| 上流コミット | `c1b80eaa09fe13d5f12b1599d1ae4d53c224de30` |
| 記録 | `third_party/YaneuraOu/SOURCE_COMMIT.txt` |
| パッチ | `patches/android-pthread.patch` と `patches/nnue-neon-layout.patch` を適用済み |
| ビルド | `tools/build_android.ps1` |

`nn.bin` はこのリポジトリに置かない。Flutterの画面とまもにゃの素材も置かない。

2026-10-03に再現ビルドを確認。固定日付とリリース識別子は BUILD.md を参照。演算コードの変更はない。
