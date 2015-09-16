#find all aspx and asp files and output to a text file
#( get-childitem \\sun-vmweb-qa1\e$\codemaster -recurse | where-object {$_.name -match “^*.asp$” -or $_.name -match "^*.aspx$" } |
# sort directory | select-object fullname |  ft -hidetableheaders | out-file d:\1\allfiles.txt ) 

<#
    new-item d:\1\ldcdefaultlc_refs.txt -type file -force
    new-item d:\1\ldcdefaultmain_refs.txt -type file -force
    get-content d:\1\allfiles.txt | foreach-object { 
        if ([string]$_ -ne "")
        {
            $result = Select-string -path $_ "ldcdefaultlc.css" 
            if ([string]$result -ne "") { add-content d:\1\ldcdefaultlc_refs.txt $_ }        
            $result = Select-string -path $_ "ldcdefaultmain.css" 
            if ([string]$result -ne "") { add-content d:\1\ldcdefaultmain_refs.txt $_ }
        }
    }
 
#>
    $searchstring = "fullName"
    new-item D:\docs\development\powershell\searchresults.txt -type file -force
    get-content D:\docs\development\powershell\allui.txt | foreach-object { 
        if ([string]$_ -ne "")
        {
            $result = Select-string -path $_ $searchstring  
            if ([string]$result -ne "") { add-content D:\docs\development\powershell\searchresults.txt $_ }                  
        }
    }
 