$ErrorActionPreference = 'Stop'
node (Join-Path $PSScriptRoot 'install.cjs') uninstall @args
exit $LASTEXITCODE
