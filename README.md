# まも将棋で使うやねうら王

このリポジトリは、まも将棋に同梱するやねうら王バイナリの対応ソースと、Android向け再ビルド手順だけを置く。Flutterの画面、まもにゃの素材、対局画像、アドバイス文は含めない。

## 上流

- https://github.com/yaneurao/YaneuraOu
- コミット `c1b80eaa09fe13d5f12b1599d1ae4d53c224de30`
- ライセンス: GNU GPL-3.0（`LICENSE`）

対応ソースは `third_party/YaneuraOu` に同梱してある。`SOURCE_COMMIT.txt` が上流コミットで、`patches/android-pthread.patch` は適用済みである。ビルドスクリプトはこのツリーだけを使い、上流から clone しない。

## 再ビルド

```powershell
powershell -ExecutionPolicy Bypass -File tools\build_android.ps1
```

成果物は `out/libyaneuraou.so`。評価関数 `nn.bin` はこのリポジトリに置かない。入手とライセンスの状態は `EVAL_FUNCTION.md`。

ビルド定義の詳細は `BUILD.md`。対応ソースをどこへ残すかは `CORRESPONDING_SOURCE.md`。
