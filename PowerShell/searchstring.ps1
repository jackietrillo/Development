Param($tempfolder,$version)
$tempfolder = "D:\output\LDC"
$findtext = "font"


#$ErrorActionPreference = "stop"
$scriptdir = split-path $myinvocation.mycommand.path -parent
$outfile = $scriptdir + "\searchresults.txt" 
new-item $outfile -type file -force

try
{

    $files = get-childitem $tempfolder -recurse | where-object { $_.PSIsContainer -eq $false -and $_.Extension -match “aspx|ascx|asp|htm|html|js|cs|css”}    
    $files |  foreach-object {     
      #$filecontents = Get-Content $_.fullname     
      #set-itemproperty $_.fullname -name IsReadOnly -value $false           
      #$filecontents | foreach-object {                
	    if ([string]$_ -ne "")
        {
            $result = select-string -path $_.fullname $findtext  
            if ([string]$result -ne "") { add-content $outfile $_.fullname }                  
        }
	 # }
    }
  
    Read-Host "Press enter to quit.."
    exit 0
	
}
catch [Exception]
{
   $message = "searchstring.ps1: " + $_.Exception.Message 
   write-warning $message
   exit -1
}





