$ErrorActionPreference = 'Stop'
node (Join-Path $PSScriptRoot 'install.cjs') install
exit $LASTEXITCODE
