function switchbranch()
{	        
    registercom    
	write-host "Switching Website to new branch"
	$sitename = "Default Web Site/"
	& $env:windir\system32\cmd.exe /C "$env:windir\syswow64\inetsrv\appcmd.exe set vdir `"$sitename`" -physicalpath:D:\Taleo\$newbranch\Learn.com\LDC\Web\LearnCenter"

    $sitename = "Default Web Site/custom"
    $newcustom = "custom_$newbranch"
    #switchcustomdir($newcustom)
    
	write-host "Branch switched successfully"
}

function registercom()
{   	     
    write-host "Unregister COM dlls from current branch"
	& "D:\Taleo\$currentbranch\Learn.com\LDC\Lib\COM\unreg.bat"

	write-host "Register COM dlls from new branch"
	& "D:\Taleo\$newbranch\Learn.com\LDC\Lib\COM\reg.bat"        
}

function switchcustomdir($customfolder)
{	
    write-host "Switching custom directory for branch"   
	$physicalpath = $physicalpath  + $customfolder
	
	iisreset /stop
	$sitename = "Default Web Site/custom"
	& $env:windir\system32\cmd.exe /C "$env:windir\syswow64\inetsrv\appcmd.exe set vdir `"$sitename`" -physicalpath:$physicalpath"		
	iisreset /start
}

$physicalpath = "D:\Taleo\vdirs\"	

do
{   
    write-host "`nPlease select an option from the menu:`n"
    write-host "`t1. List current site details"
    write-host "`t2. Switch to a different branch"    
    write-host "`t3. Switch custom folder"
    write-host "`t4. Unregister/register COM libraries"
    write-host "`t5. Quit"

    $input = Read-host
  
	switch($input)
	{
		"1" { & $env:windir\system32\cmd.exe /C "$env:windir\syswow64\inetsrv\appcmd.exe list vdir" }
		"2" {
				write-host "Please enter the name of the current branch:"
				$currentbranch = read-host
				write-host "Please enter the name of the new branch:"
				$newbranch = read-host			
				switchbranch					
			}
		"3" {
				write-host "Please enter the name of the custom folder (physical):"
				$folder= read-host
				iisreset /stop
				switchcustomdir($folder)
				iisreset /start
				write-host "Custom directory switched successfully"
			}			
		"4"
			{
				write-host "Please enter the name of the current branch:"
				$currentbranch = read-host

				write-host "Please enter the name of the new branch:"
				$newbranch = read-host

				iisreset /stop
				registercom
				iisreset /start
			}				
		"5" {		
				write-host "Good bye!"
			}
		Default 
		{
		     write-host "You must enter a valid integer in the range (1-5). Try again."
		}
	}           
} while ($input -ne "5") 

exit 0
