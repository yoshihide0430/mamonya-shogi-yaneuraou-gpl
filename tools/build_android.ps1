param(
    [string]$Commit = "c1b80eaa09fe13d5f12b1599d1ae4d53c224de30"
)

$ErrorActionPreference = "Stop"
$Root = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$Source = Join-Path $Root "third_party\YaneuraOu"
$Build = Join-Path $Root "build"
$Out = Join-Path $Root "out\obj"
$Libs = Join-Path $Root "out\libs"

$Recorded = Join-Path $Source "SOURCE_COMMIT.txt"
if (-not (Test-Path $Source) -or -not (Test-Path $Recorded)) {
    throw "Corresponding source is missing at $Source. This script does not clone upstream."
}
$Stored = (Get-Content $Recorded -Raw).Trim()
if ($Stored -ne $Commit) {
    throw "SOURCE_COMMIT.txt is $Stored, expected $Commit"
}
$Header = Join-Path $Source "source\thread_win32_osx.h"
$HeaderText = Get-Content $Header -Raw
if ($HeaderText -notmatch "__ANDROID__") {
    throw "android-pthread.patch is not present in the stored source"
}

$SparseHeader = Join-Path $Source "source\eval\nnue\layers\affine_transform_sparse_input.h"
$SparseText = Get-Content $SparseHeader -Raw
if ($SparseText -match 'defined\(USE_SSSE3\) \|\| USE_NEON >= 8') {
    throw "Known-broken plain-NEON NNUE sparse layout condition is present"
}
if ($SparseText -notmatch 'defined\(USE_SSSE3\) \|\| defined\(USE_NEON_DOTPROD\)') {
    throw "Validated nnue-neon-layout patch is missing"
}

$Sdk = $env:ANDROID_SDK_ROOT
if (-not $Sdk) { $Sdk = $env:ANDROID_HOME }
if (-not $Sdk) { $Sdk = "$env:LOCALAPPDATA\Android\Sdk" }
$Ndk = $env:ANDROID_NDK_HOME
if (-not $Ndk -or -not (Test-Path $Ndk)) {
    $NdkRoot = Join-Path $Sdk "ndk"
    $Ndk = (Get-ChildItem $NdkRoot -Directory | Where-Object { $_.Name -like "28.2.*" } | Select-Object -First 1).FullName
    if (-not $Ndk) {
        $Ndk = (Get-ChildItem $NdkRoot -Directory | Sort-Object Name -Descending | Select-Object -First 1).FullName
    }
}
$NdkBuild = Join-Path $Ndk "ndk-build.cmd"
if (-not (Test-Path $NdkBuild)) { throw "ndk-build.cmd not found: $NdkBuild" }
Write-Host "NDK: $Ndk"
Write-Host "Commit: $Commit"

# Only remove the two explicitly resolved output directories within this checkout.
foreach ($Target in @($Out, $Libs)) {
    $FullTarget = [IO.Path]::GetFullPath($Target)
    $ExpectedParent = [IO.Path]::GetFullPath((Join-Path $Root "out"))
    if ((Split-Path $FullTarget -Parent) -ne $ExpectedParent) {
        throw "Output directory is outside the expected out directory: $FullTarget"
    }
    if (Test-Path -LiteralPath $FullTarget) { Remove-Item -LiteralPath $FullTarget -Recurse -Force }
}

# The production binary embeds __DATE__. Fix it to its validated build date
# (2026-09-27 UTC) so a later rebuild preserves the exact production identity.
$PreviousEpoch = $env:SOURCE_DATE_EPOCH
$env:SOURCE_DATE_EPOCH = "1790467200"
try {

& $NdkBuild `
    "NDK_PROJECT_PATH=$Root" `
    "APP_BUILD_SCRIPT=$Build\Android.mk" `
    "NDK_APPLICATION_MK=$Build\Application.mk" `
    "NDK_OUT=$Out" `
    "NDK_LIBS_OUT=$Libs" `
    -j4
if ($LASTEXITCODE -ne 0) { throw "ndk-build failed" }
} finally {
    $env:SOURCE_DATE_EPOCH = $PreviousEpoch
}

$Built = Join-Path $Libs "arm64-v8a\yaneuraou"
if (-not (Test-Path $Built)) { throw "executable not found: $Built" }
$Final = Join-Path $Root "out\libyaneuraou.so"
Copy-Item $Built $Final -Force
$Hash = (Get-FileHash $Final -Algorithm SHA256).Hash.ToLowerInvariant()
$Hash | Set-Content (Join-Path $Root "out\libyaneuraou.sha256") -Encoding ascii
Write-Host "Built: $Final"
Write-Host "SHA-256: $Hash"
Write-Host "Validated production SHA-256: 28647dbf16571809dc4713950bd121b87c28b33436516ee2976a14f13d5dc6e7"
Write-Host "The official app copies this file to android/app/src/main/jniLibs/arm64-v8a/libyaneuraou.so"
