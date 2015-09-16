write-host "---creating folders---"
new-item "c:\Taleo\Trunk" -itemtype directory -force
new-item "c:\Taleo\trunk\Learn.com\LDC\Web\LearnCenter\helloworld.htm" -itemtype file -force
get-item "c:\Taleo\trunk\Learn.com\LDC\Web\LearnCenter\helloworld.htm" 
add-content "c:\Taleo\trunk\Learn.com\LDC\Web\LearnCenter\helloworld.htm" "<h1>Hello, World!!!!</h1>"
new-item "c:\Taleo\vdirs_trunk" -itemtype directory -force
new-item "c:\Taleo\vdirs_trunk\_ldc_custom" -itemtype directory -force
new-item "c:\Taleo\vdirs_trunk\_ldc_files" -itemtype directory -force

write-host "---creating junctions j_files and j_custom---"
copy-item junction.exe c:\taleo
c:\Taleo\junction.exe -d c:\taleo\j_files 
c:\Taleo\junction.exe -d c:\taleo\j_custom 
c:\Taleo\junction.exe c:\taleo\j_files "c:\Taleo\vdirs_trunk\_ldc_files"
c:\Taleo\junction.exe c:\taleo\j_custom "c:\Taleo\vdirs_trunk\_ldc_custom"

#write-host "---getting source https://engineering.tbetaleo.com/svn/dev/learn/trunk---"

#C:\Windows\SysWOW64\cmd.exe /C "%systemroot%\syswow64\inetsrv\appcmd.exe list sites"
write-host "---IIS configuration---"
cmd.exe /C "%systemroot%\syswow64\inetsrv\appcmd.exe set config /section:asp /appAllowClientDebug:true"
cmd.exe /C "%systemroot%\syswow64\inetsrv\appcmd.exe set config /section:asp /AppAllowDebugging:true"
cmd.exe /C "%systemroot%\syswow64\inetsrv\appcmd.exe set config /section:asp /scriptErrorSentToBrowser:true"
cmd.exe /C "%systemroot%\syswow64\inetsrv\appcmd.exe set config /section:asp /codePage:65001"
cmd.exe /C "%systemroot%\syswow64\inetsrv\appcmd.exe set apppool /apppool.name:DefaultAppPool /enable32BitAppOnWin64:true"
cmd.exe /C "%systemroot%\syswow64\inetsrv\appcmd.exe set config /section:defaultDocument /+files.[value='errorpage.htm']" 
cmd.exe /C "%systemroot%\syswow64\inetsrv\appcmd.exe set config /section:anonymousAuthentication /enabled:true" 
cmd.exe /C "%systemroot%\syswow64\inetsrv\appcmd.exe set config /section:windowsAuthentication /enabled:true" 
cmd.exe /C "%systemroot%\syswow64\inetsrv\appcmd.exe set config /section:httpErrors /errorMode:Custom"
cmd.exe /C "%systemroot%\syswow64\inetsrv\appcmd.exe set config /section:httpErrors /[statusCode='404'].responseMode:ExecuteURL"
cmd.exe /C "%systemroot%\syswow64\inetsrv\appcmd.exe set config /section:httpErrors /[statusCode='404'].prefixLanguageFilePath:"
cmd.exe /C "%systemroot%\syswow64\inetsrv\appcmd.exe set config /section:httpErrors /[statusCode='404'].path:/errorpage.htm"


write-host "---creating website---"
cmd.exe /C "%systemroot%\syswow64\inetsrv\appcmd.exe delete site trunk"
#cmd.exe /C "%systemroot%\syswow64\inetsrv\appcmd.exe delete apppool trunkAppPool"
cmd.exe /C "%systemroot%\syswow64\inetsrv\appcmd.exe add site /name:trunk /physicalpath:C:\Taleo\Trunk\Learn.com\LDC\Web\LearnCenter"
cmd.exe /C "%systemroot%\syswow64\inetsrv\appcmd.exe set site /site.name:trunk /+bindings.[protocol='http',bindingInformation='*:80:']" 


# cmd.exe /C "%systemroot%\syswow64\inetsrv\appcmd.exe add apppool /name:trunkAppPool"
# cmd.exe /C "%systemroot%\syswow64\inetsrv\appcmd.exe set app trunk/ /applicationPool:trunkAppPpol"
cmd.exe /C "%systemroot%\syswow64\inetsrv\appcmd.exe add vdir /app.name:trunk/ /path:/files /physicalpath:C:\Taleo\j_files"
cmd.exe /C "%systemroot%\syswow64\inetsrv\appcmd.exe add vdir /app.name:trunk/ /path:/custom /physicalpath:C:\Taleo\j_custom"
