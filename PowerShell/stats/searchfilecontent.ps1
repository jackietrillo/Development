 (
get-childitem -path c:\learncenter -include "*.aspx" -recurse | 
foreach { 
    $filename = $_.fullname; 
    get-content $_.fullname;  | foreach {
                $filefound = $false
                if([string]$_.tolower().indexof("controlpanel.css")) 
                {
                    $filefound = $true;                   
                }
            }   if ($filefound -eq $true) {write-host $filename;}   
        } 
 )