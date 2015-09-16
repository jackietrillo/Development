
<#
$tempfolder = "C:\builds\Learn.com.2013.11.0.60"
get-childitem $tempfolder -recurse -force | where-object { 
if ($_.psiscontainer -eq $true -and $_.name -eq ".svn" -and $_.mode -eq "d--h-") {
        $message = "deleting " + [string]$_.FullName
        write-host $message
        remove-item $_.FullName -force -recurse
    }            
}
#>
$tempfolder = "\\SUN-LCDB-QA\f$\MSSQL\scripts\trunk\14.8.5"
get-childitem $tempfolder -include *.log -recurse | foreach ($_) { remove-item $_.fullname }




