$inputfile = "D:\docs\development\powershell\input.txt"
$outputfile = "D:\docs\development\powershell\output.txt"
$logfile = "D:\docs\development\powershell\log.txt"

if (test-path $logfile)
{
	remove-item $logfile -force
}
if (test-path $outputfile)
{
	remove-item $outputfile -force
}
new-item $logfile -type f -force 
new-item $outputfile -type f -force 

get-content $inputfile | foreach {  
    $file = $_ 
    if (test-path $file)
    {
        get-content $file | add-content $outputfile
		
		add-content $outputfile "`r`n"
    }
    else
    {
        $logmessage = $file + " not found"
        add-content $logfile $logmessage
    }         
} 
write-host "completed"
Read-host
#cat lc_sp_IOB_AuditLog.sql D:\Taleo\trunk\Database\Sql\2013.32.0.0\pre\0430_13C.2_AuditTrail_DDL.sql > D:\Taleo\trunk\Database\Sql\2013.32.0.0\pre\0430_13C.2_AuditTrail_DDL.sql