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
-DUSE_NEON_DOTPROD
-march=armv8.2-a+dotprod
-DHASH_KEY_BITS=128
-DTT_CLUSTER_SIZE=4
-DTARGET_CPU="ARMV8_DOTPROD"
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
