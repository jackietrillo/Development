param($param1=1, [string]$param2, [switch]$u)

if ($param1 -ne $null)
{
	write-host $param1
}
else
{
	write-host "`$param1 is null"
}
if ($param2 -ne $null)
{
	write-host $param2
	write-host $param2.getType()
}
else
{
	write-host "`$param2 is null"
}

if ($param3 -ne $null)
{
	write-host $param3
}
else
{
	write-host "`$param3 is null"
}

if($u -eq $true)
{
	write-host "`$u was supplied. The value is true"
}
