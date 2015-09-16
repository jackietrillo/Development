$tempdir =  "d:\taleo\trunk\learn.com\ldc\web\learncenter"

#get-childitem $tempdir -recurse | where { $_.PSIsContainer -eq $true -and $_.name -like "*image*" } |
#where { ($_.fullname -notlike "*crystal*") -and ($_.fullname -notlike "*cuteeditor*") } | select-object fullname | out-file allimage.txt


#get-childitem $tempdir -recurse | where { $_.PSIsContainer -eq $false -and $_.Extension -eq ".js" } |
#where { ($_.fullname -notlike "*crystal*") -and ($_.fullname -notlike "*cuteeditor*") } | select-object fullname | out-file alljs.txt


get-childitem $tempdir -recurse | where { $_.PSIsContainer -eq $false -and $_.extension -like ".css" } |
where { ($_.fullname -notlike "*crystal*") -and ($_.fullname -notlike "*cuteeditor*") } | select-object fullname | out-file allcss.txt
