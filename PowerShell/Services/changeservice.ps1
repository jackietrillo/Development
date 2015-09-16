Param($servername, $servicename)
#$servicename = "LearnScheduler"
$servicename = "LDCMessageQueueService*"
if($servername -eq $null)
{
    $servername = "."
}

$services= (get-wmiobject win32_service -computername $servername | Where {$_.name -like "$servicename"})    
foreach($service in $services) 
{
    if ($service -ne $null)
    {
    	$service.InvokeMethod("StopService", $null)
        $service.change($null,$null,$null,$null,$null,$null,"webster_qa","%57~DJV?",$null,$null,$null)
        $service.InvokeMethod("startservice", $null) 
    }
}
