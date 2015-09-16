Param($sitename, $rootfolder)
 
$sitename = "patch"
$rootfolder = "14.2.2"
 
#& $env:windir\system32\cmd.exe /C "$env:windir\syswow64\inetsrv\appcmd.exe delete site $sitename"
#& $env:windir\system32\cmd.exe /C "$env:windir\syswow64\inetsrv\appcmd.exe delete apppool $sitename"

& $env:windir\system32\cmd.exe /C "$env:windir\syswow64\inetsrv\appcmd.exe add site /name:$sitename /physicalpath:D:\Taleo\$rootfolder\Learn.com\LDC\Web\LearnCenter"
& $env:windir\system32\cmd.exe /C "$env:windir\syswow64\inetsrv\appcmd.exe set site /site.name:$sitename /+bindings.[protocol='http',bindingInformation='*:80:$sitename']"
& $env:windir\system32\cmd.exe /C "$env:windir\syswow64\inetsrv\appcmd.exe add apppool /name:$sitename"
& $env:windir\system32\cmd.exe /C "$env:windir\syswow64\inetsrv\appcmd.exe set app $sitename/ /applicationPool:$sitename"
& $env:windir\system32\cmd.exe /C "$env:windir\syswow64\inetsrv\appcmd.exe set apppool /apppool.name:$sitename /enable32BitAppOnWin64:true"
& $env:windir\system32\cmd.exe /C "$env:windir\syswow64\inetsrv\appcmd.exe add vdir /app.name:$sitename/ /path:/files /physicalpath:D:\Taleo\j_files"
& $env:windir\system32\cmd.exe /C "$env:windir\syswow64\inetsrv\appcmd.exe add vdir /app.name:$sitename/ /path:/custom /physicalpath:D:\Taleo\j_custom"


exit 0
