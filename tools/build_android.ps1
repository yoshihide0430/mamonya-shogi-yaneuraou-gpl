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

if (Test-Path $Out) { Remove-Item $Out -Recurse -Force }
if (Test-Path $Libs) { Remove-Item $Libs -Recurse -Force }

& $NdkBuild `
    "NDK_PROJECT_PATH=$Root" `
    "APP_BUILD_SCRIPT=$Build\Android.mk" `
    "NDK_APPLICATION_MK=$Build\Application.mk" `
    "NDK_OUT=$Out" `
    "NDK_LIBS_OUT=$Libs" `
    -j4
if ($LASTEXITCODE -ne 0) { throw "ndk-build failed" }

$Built = Join-Path $Libs "arm64-v8a\yaneuraou"
if (-not (Test-Path $Built)) { throw "executable not found: $Built" }
Copy-Item $Built (Join-Path $Root "out\libyaneuraou.so") -Force
Write-Host "Built: $Root\out\libyaneuraou.so"
Write-Host "The official app copies this file to android/app/src/main/jniLibs/arm64-v8a/libyaneuraou.so"
