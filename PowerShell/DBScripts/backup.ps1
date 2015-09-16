param(
  $location = "D:\backups\",
  $dbserver = "(local)",
  $user = "sa",
  $pwd = "devv")

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null
[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
  
$server = new-object Microsoft.SqlServer.Management.Smo.Server($dbserver)
$server.ConnectionContext.DatabaseName = "master"
$server.ConnectionContext.LoginSecure = $false
$server.ConnectionContext.Login = $user
$server.ConnectionContext.Password = $pwd
$server.ConnectionContext.StatementTimeout = 0

$db = new-object Microsoft.SqlServer.Management.Smo.Database
$db = $server.Databases.Item("master")
$ds = $db.ExecuteWithResults("select name from sys.databases where name not in (N'master', N'msdb', N'tempdb', N'model')")
foreach ($r in $ds.Tables[0].Rows)
{
$database = $r[0];

$file = $location + $database + ".bak"

echo ("backup from " + $dbserver + " of database " + $database + " to file " + $file)

$device = new-object Microsoft.SqlServer.Management.Smo.BackupDeviceItem($file, [Microsoft.SqlServer.Management.Smo.DeviceType]::File)
$device.DeviceType = [Microsoft.SqlServer.Management.Smo.DeviceType]::File
$device.Name = $file

$backup = new-object Microsoft.SqlServer.Management.Smo.Backup
$backup.Action = [Microsoft.SqlServer.Management.Smo.BackupActionType]::Database
$backup.Database = $database
$backup.NoRecovery = $true
$backup.NoRewind = $true
$backup.LogTruncation = [Microsoft.SqlServer.Management.Smo.BackupTruncateLogType]::Truncate
$backup.Devices.Add($device)
$backup.CompressionOption = [Microsoft.SqlServer.Management.Smo.BackupCompressionOptions]::On

# for the case backup file exists and we need to force delete it.
If (Test-Path $file){
	Remove-Item $file
}

$backup.SqlBackup($server)
}
