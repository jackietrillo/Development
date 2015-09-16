Param($tempfolder,$version)
$tempfolder = "D:\Taleo\13.14_prod\Learn.com\LDC\Web\LearnCenter\LCNet\ControlPanel\SkillComp\Job*.aspx"
$findtext = '<link rel="stylesheet" href="/controlPanel/includes/controlPanel.css"  />'
$findtext = "<link[^>]*controlpanel.css[^>]*/>"


#$ErrorActionPreference = "stop"
$scriptdir = split-path $myinvocation.mycommand.path -parent
$outfile = $scriptdir + "\foundfiles.txt" 
try
{

    $files = get-childitem $tempfolder -recurse | where-object { $_.name -match "^*.asp$|^*.aspx$" }
    
    $files |  foreach-object {
      $filename =  $_.fullname      
      $filecontents = Get-Content $filename      
      set-itemproperty $filename -name IsReadOnly -value $false           
      $filecontents | foreach-object { if ($_ -match $findtext){ $_.replace( $matches[0];} }                  

    }
  
    exit 0
}
catch [Exception]
{
   $message = "findinfiles.ps1: " + $_.Exception.Message 
   write-warning $message
   exit -1
}





