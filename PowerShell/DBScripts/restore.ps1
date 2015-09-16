param(
  $location = "D:\backups\",
  $mdfLocation = "D:\databases\",
  $ldfLocation = "D:\databases\",
  $mdfSuffix = "_data",
  $ldfSuffix = "_log",
  $dbserver = "(local)",
  $user = "sa",
  $pwd = "devv")

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null

$files = (ls -filter *.bak $location -name)

foreach ($file in $files)
{
$file = $location + $file

$server = new-object Microsoft.SqlServer.Management.Smo.Server($dbserver)
$server.ConnectionContext.DatabaseName = "master"
$server.ConnectionContext.LoginSecure = $false
$server.ConnectionContext.Login = $user
$server.ConnectionContext.Password = $pwd
$server.ConnectionContext.StatementTimeout = 0

$device = new-object Microsoft.SqlServer.Management.Smo.BackupDeviceItem($file, [Microsoft.SqlServer.Management.Smo.DeviceType]::File)
$device.DeviceType = [Microsoft.SqlServer.Management.Smo.DeviceType]::File
$device.Name = $file

$restore = new-object Microsoft.SqlServer.Management.Smo.Restore
$restore.Action = [Microsoft.SqlServer.Management.Smo.RestoreActionType]::Database
$restore.NoRecovery = $false
$restore.ReplaceDatabase = $true
$restore.Devices.Add($device)

$details = $restore.ReadBackupHeader($dbserver)
$database = $details.Rows[0]["DatabaseName"]
$restore.Database = $database

echo ("restore backup to " + $dbserver + " of database " + $database + " from file " + $file)

$files = $restore.ReadFileList($dbserver)

foreach ($file in $files)
{
    if ($file.Type -eq "D")
	{
	    $mdfFile = new-object Microsoft.SqlServer.Management.Smo.RelocateFile
        $mdfFile.PhysicalFileName = $mdfLocation + $database + $mdfSuffix + ".mdf"
        $mdfFile.LogicalFileName = $file.LogicalName
        $restore.RelocateFiles.Add($mdfFile) > $null
	}
	if ($file.Type -eq "L")
	{
        $ldfFile = new-object Microsoft.SqlServer.Management.Smo.RelocateFile
        $ldfFile.PhysicalFileName = $ldfLocation + $database + $ldfSuffix + ".ldf"
        $ldfFile.LogicalFileName = $file.LogicalName
        $restore.RelocateFiles.Add($ldfFile) > $null
	}
}

# for the case database exists and we need to force delete it.
# $server.Databases[$database].Drop()

$restore.SqlRestore($server)
}
