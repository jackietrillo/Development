$scriptdir = split-path $myinvocation.mycommand.path -parent
$functions = $scriptdir + "\functions.ps1"
. $functions


saysomething2 "hello from f1"