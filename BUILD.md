# 2026-10-03 再現ビルドの修正

tools/build_android.ps1 の再ビルドで、現行アプリと同一のSHA-256を確認した。

- 日付: SOURCE_DATE_EPOCH=1790467200（2026-09-27 UTC）で __DATE__ を固定。
- GNU build-id: 02d2e2208ac37ea5e76d465da51afcd578074ecf を現行リリースの識別子として Android.mk で固定。
- 日付固定のみの出力は、配布物とGNU build-idの20バイトだけが異なった。デバッグ情報のパスで識別子が変わるため、リリースIDも固定する。これは内容ハッシュではない。内容同一性は下記SHA-256で別途確認する。
- SHA-256: 28647dbf16571809dc4713950bd121b87c28b33436516ee2976a14f13d5dc6e7、1162064 bytes。
- out/libyaneuraou.so、out/libs/arm64-v8a/yaneuraou、アプリ同梱バイナリが一致。
- SOURCE_DATE_EPOCH はスクリプト終了時に元の値へ戻す。
- 再帰削除前に、対象がこのチェックアウトの out/obj または out/libs の直下であることを確認する。
- 接続端末のNNUE NEON数値回帰テスト: 不一致0/512。

ソースを変更した際は同一内容という扱いにしない。SHA-256が一致しない場合、アプリ側の取り込みスクリプトは従来通り拒否する。

以下は2026-09-27までのビルド履歴。

# 2026-09-27 NNUE NEON評価計算修正版（現在の正本）

ARMv8-A + NEON互換版のNNUE sparse affine層の重み配置不一致を修正しました。
以下の2026-09-26のB1EB…および旧DOTPRODのCDBD…は履歴です。

- サイズ：1162064 bytes
- SHA-256：`28647dbf16571809dc4713950bd121b87c28b33436516ee2976a14f13d5dc6e7`
- 上流基点：`c1b80eaa09fe13d5f12b1599d1ae4d53c224de30`
- 追加修正：`patches/nnue-neon-layout.patch`（格納ソースには適用済み）
- ビルド設定：ARMv8-A / USE_NEON=8 / DOTPRODなし / Hash128 / cluster4 / Ofast / LTO。変更なし。
- 詳細・実機検証：`NNUE_NEON_FIX_20260927.md`
- 回帰テスト：`tools/test_nnue_layout.ps1`（Pixel 9a等のADB接続端末）

# 2026-09-26 ARM64互換ビルド

この配布物はARMv8-A + NEONを使用し、DOTPROD拡張命令を必須にしない構成です。エンジンのロジック・上流コミット・pthreadパッチは同一です。今回のlibyaneuraou.so SHA-256: B1EB8B2D8DFB5191A1E46CA84E04B391948DFB2E5935C130C02D24C0CC3B3896

以下は既存のビルド説明です。末尾の過去のハッシュは今回の成果物とは異なります。

# Androidビルド

同梱した `libyaneuraou.so` は、次の条件で作った実行ファイルをその名前にリネームしたものである。

| 項目 | 値 |
| --- | --- |
| 上流 | https://github.com/yaneurao/YaneuraOu |
| コミット | `c1b80eaa09fe13d5f12b1599d1ae4d53c224de30` |
| パッチ | `patches/android-pthread.patch` |
| NDK | 28.2.13676358 |
| コマンド | `ndk-build`（`tools/build_android.ps1`） |
| ABI | `arm64-v8a` のみ |
| プラットフォーム | `android-24` |
| STL | `c++_static` |
| 最適化 | `APP_OPTIM=release` |
| 出力 | `BUILD_EXECUTABLE`。配置名は `libyaneuraou.so` |

コンパイルオプションの正本は `build/Android.mk` の `LOCAL_CPPFLAGS` と `LOCAL_LDFLAGS`。

```text
-std=c++17
-fno-exceptions
-fno-rtti
-Ofast
-flto
-pthread
-fPIE
-DNDEBUG
-D_LINUX
-DUNICODE
-DNO_EXCEPTIONS
-DUSE_MAKEFILE
-DYANEURAOU_ENGINE_NNUE
-DUSE_PTHREADS
-DIS_64BIT
-DUSE_NEON=8

-march=armv8-a
-DHASH_KEY_BITS=128
-DTT_CLUSTER_SIZE=4
-DTARGET_CPU="ARMV8_NEON"
-DENGINE_NAME_FROM_MAKEFILE=YaneuraOu_MamoShogi
-D__STDINT_MACROS
-D__STDC_LIMIT_MACROS
```

リンカ:

```text
-fPIE -pie -flto -pthread
```

翻訳単位の一覧も `build/Android.mk` の `LOCAL_SRC_FILES` が正本。評価関数ファイルはビルドに含めない。

## 今回の成果物

NDK 28.2.13676358 で `tools/build_android.ps1` を実行し、`patches/android-pthread.patch` を適用したあと本体へ入れた。

| 項目 | 値 |
| --- | --- |
| ファイル | `libyaneuraou.so` |
| サイズ | 1167840 バイト |
| SHA-256 | `cdbdddd031bcae0e73b62f9e426fbbab39c13551bc0384f32253502b3837ab99` |
| LOAD の Align | `0x4000`（16KB） |

`__ANDROID__` の追加は、`Android.mk` が既に `-DUSE_PTHREADS` を渡しているため、コンパイルされる分岐はパッチ前と同じである。LOAD セグメントの整列は NDK 28 の既定で 16KB になっている。

