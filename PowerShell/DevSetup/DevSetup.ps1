<#  Required Installs: IIS 7.0, Tortoise SVN, Sql Server #>

& "$env:windir\syswow64\inetsrv\appcmd.exe" add backup "IISBackup1"

tortoiseproc.exe /command:checkout /url:https://engineering.tbetaleo.com/svn/dev/learn/trunk /path:d:\Taleo\Trunk

new-item "D:\Taleo\vdirs_trunk" -itemtype directory -force
new-item "D:\Taleo\vdirs_trunk\_ldc_custom" -itemtype directory -force
new-item "D:\Taleo\vdirs_trunk\_ldc_files" -itemtype directory -force
copy-Item D:\Taleo\trunk\Learn.com\LDC\Web\LearnCenter\custom D:\Taleo\vdirs_trunk -force -recurse
remove-item "D:\Taleo\vdirs_trunk\_ldc_custom\temp" -force -recurse
remove-item "D:\Taleo\vdirs_trunk\_ldc_custom\.svn" -force -recurse

& "$env:windir\syswow64\inetsrv\appcmd.exe" set config /section:asp /appAllowClientDebug:true
& "$env:windir\syswow64\inetsrv\appcmd.exe" set config /section:asp /AppAllowDebugging:true
& "$env:windir\syswow64\inetsrv\appcmd.exe" set config /section:asp /scriptErrorSentToBrowser:true
& "$env:windir\syswow64\inetsrv\appcmd.exe" set config /section:asp /codePage:65001
& "$env:windir\syswow64\inetsrv\appcmd.exe" set apppool /apppool.name:DefaultAppPool /enable32BitAppOnWin64:true
& "$env:windir\syswow64\inetsrv\appcmd.exe" set config /section:defaultDocument /+files.[value='errorpage.htm'] 
& "$env:windir\syswow64\inetsrv\appcmd.exe" set config /section:anonymousAuthentication /enabled:true 
& "$env:windir\syswow64\inetsrv\appcmd.exe" set config /section:windowsAuthentication /enabled:true 
& "$env:windir\syswow64\inetsrv\appcmd.exe" set config /section:httpErrors /errorMode:Custom
& "$env:windir\syswow64\inetsrv\appcmd.exe" set config /section:httpErrors /[statusCode='404'].responseMode:ExecuteURL
& "$env:windir\syswow64\inetsrv\appcmd.exe" set config /section:httpErrors /[statusCode='404'].prefixLanguageFilePath:
& "$env:windir\syswow64\inetsrv\appcmd.exe" set config /section:httpErrors /[statusCode='404'].path:/errorpage.htm
& "$env:windir\syswow64\inetsrv\appcmd.exe" add vdir /app.name:"Default Web Site/" /path:/files /physicalpath:D:\Taleo\vdirs_trunk\_ldc_files
& "$env:windir\syswow64\inetsrv\appcmd.exe" add vdir /app.name:"Default Web Site/" /path:/custom /physicalpath:D:\Taleo\vdirs_trunk\_ldc_custom
& "$env:windir\syswow64\inetsrv\appcmd.exe" set vdir /vdir.name:"Default Web Site/" /physicalpath:D:\Taleo\Trunk\Learn.com\LDC\Web\LearnCenter

D:\Taleo\trunk\Learn.com\LDC\Lib\COM\reg.bat

