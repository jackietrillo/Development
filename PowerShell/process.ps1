Param($processname, $action)
$servername = ".\"
$action = "stop"

$processes= (get-wmiobject win32_process -computername $servername | Where {$_.name -like "msbuild*"})    
foreach($process in $processes) 
{
    write-host "Stopping" $process
	if (-not ($process -eq $null))
	{                    
		stop-process $process
	}	 
}

