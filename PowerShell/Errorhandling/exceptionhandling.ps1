$ErrorActionPreference = "stop"

try
{
   "out-file" | out-file "d:\1\test.txt" 
   #get-content $logfile
    
   exit 0
}
catch [Exception] {
    if ($_.Exception.GetType().FullName -eq "System.Management.Automation.ItemNotFoundException")
    {        
        exit -1
    }      
    if ($_.Exception.GetType().FullName -eq "System.IO.DirectoryNotFoundException")
    {
        Write-warning "could not create directory"
        exit -1
    }       
    else
    {
         Write-warning $_.Exception.GetType().FullName
    }
}

