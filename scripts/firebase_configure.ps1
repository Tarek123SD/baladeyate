$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot\..

# Use Flutter's Dart SDK (not a legacy system Dart install on PATH).
$flutterBin = (Get-Command flutter).Source | Split-Path -Parent
$env:PATH = "$flutterBin;$PWD\node_modules\.bin;$env:LOCALAPPDATA\Pub\Cache\bin;$env:PATH"

dart pub global activate flutterfire_cli
dart pub global run flutterfire_cli:flutterfire configure --yes --project=balditi --platforms=android,ios
