$ErrorActionPreference = 'Stop'
node (Join-Path $PSScriptRoot 'install.cjs') uninstall
exit $LASTEXITCODE
