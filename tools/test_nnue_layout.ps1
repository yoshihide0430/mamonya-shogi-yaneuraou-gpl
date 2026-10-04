param(
    [string]$Ndk = "$env:LOCALAPPDATA\Android\Sdk\ndk\28.2.13676358",
    [string]$Adb = "$env:LOCALAPPDATA\Android\Sdk\platform-tools\adb.exe",
    [switch]$Dotprod
)
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$compiler = Join-Path $Ndk 'toolchains\llvm\prebuilt\windows-x86_64\bin\aarch64-linux-android24-clang++.cmd'
$source = Join-Path $root 'third_party\YaneuraOu\source'
$test = Join-Path $root 'tests\nnue_layout_test.cpp'
$out = Join-Path $root 'out\nnue-layout-tests'
New-Item -ItemType Directory -Force $out | Out-Null
$flags = @('-std=c++17', '-O3', '-DNDEBUG', '-DUSE_MAKEFILE', '-DYANEURAOU_ENGINE_NNUE', '-DIS_64BIT', '-DUSE_NEON=8', '-static-libstdc++', "-I$source")
$variant = 'neon'
if ($Dotprod) {
    $flags += @('-DUSE_NEON_DOTPROD', '-march=armv8.2-a+dotprod')
    $variant = 'dotprod'
} else {
    $flags += '-march=armv8-a'
}
$binary = Join-Path $out $variant
& $compiler @flags $test -o $binary
if ($LASTEXITCODE -ne 0) { throw 'NNUE layout test build failed' }
$remote = '/data/local/tmp/mamonya_nnue_layout'
& $Adb shell mkdir -p $remote
if ($LASTEXITCODE -ne 0) { throw 'Device not available' }
& $Adb push $binary "$remote/$variant"
if ($LASTEXITCODE -ne 0) { throw 'adb push failed' }
& $Adb shell chmod 700 "$remote/$variant"
& $Adb shell "$remote/$variant"
if ($LASTEXITCODE -ne 0) { throw 'NNUE output differs from scalar reference' }
