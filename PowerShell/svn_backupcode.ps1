#copy docs 
#copy-item D:\docs\projects\Branding \\vader\c$\temp\jackie -force -recurse
#copy-item D:\docs\projects\Branding \\w03552.wwcorp.net\d$\temp\backups -force -recurse

#get all modified files in trunk
svn status d:\taleo\trunk\Learn.com\LDC | where-object { $_.indexOf("M") -eq 0 } | foreach { $_.replace("M       ", ""); }  | Out-file d:\1\modifiedfiles.txt

#create backup folder
$folder = "d:\1\backups\code_" + [datetime]::now.tostring().Replace(" ", "_").Replace("/", "").Replace(":", "");
new-item $folder -type directory;
get-content d:\1\modifiedfiles.txt | foreach { copy-item $_ $folder } 
#remove-item d:\1\modifiedfiles.txt

#copy to backup locations
#copy-item $folder \\vader\c$\temp\jackie -force -recurse
#copy-item $folder \\w03552.wwcorp.net\d$\temp\backups -force -recurse

