$ErrorActionPreference = "stop"
$commandline = $scriptdir + "\exceptionhandling.ps1"  
invoke-expression $commandline
if ($LASTEXITCODE -eq 0)
{
    write-host "success"
    write-host $LASTEXITCODE
}
else
{
    write-host $LASTEXITCODE
}