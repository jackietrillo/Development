
(get-wmiobject win32_service -computername "W03552" -filter "name='LDCMessageQueueService'").invokemethod("stopservice", $null) 

$script = { 
  invoke-expression "%windir%\system32\msiexec.exe /qn /x 'd:\1\LDCAutomationSetup.msi'"
  while($true)
  {
    if(Get-Process msiexec -ea 0)
    {
      sleep 1
    }
    else
    {
      return
    }
  }
}

$script =  "%windir%\system32\msiexec.exe /qn /x d:\1\LDCAutomationSetup.msi"
Invoke-Command -computername "W03552" -scriptblock $script

get-help Invoke-Command

$servername = "SUN-VMWEB-QA1"
$app = Get-WmiObject win32_product -computer "W03552" | Where-Object {$_.name -like "*Roxio*"}  

write-host $app.name
