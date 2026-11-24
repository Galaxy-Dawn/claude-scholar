$ErrorActionPreference = 'Stop'
node (Join-Path $PSScriptRoot 'install.cjs') install @args
exit $LASTEXITCODE
