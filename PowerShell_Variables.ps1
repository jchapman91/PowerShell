Break 
$allservers = "jeff-lenovo\servera", "jeff-lenovo\serverb"
$allservers | Get-DbaDiskSpace | Where-Object PercentFree -lt 80
$lastbackups = $allservers | Get-DbaLastBackup
$lastbackups | Where { $_.LastLogBackup -lt (Get-Date).AddMinutes(-15) -and $_.RecoveryModel -ne "Simple" }
$lastbackups | Where LastDiffBackup -lt (Get-Date).AddDays(-1)
$lastbackups | Where LastFullBackup -lt (Get-Date).AddDays(-7)
$allservers | Get-DbaLastGoodCheckDb | Where LastGoodCheckDb -lt (Get-Date).AddDays(-1)

#Splat
$startDbaMigrationSplat = @{
    Source             = "jeff-lenovo\servera"
    Destination        = "jeff-lenovo\serverb"
    BackupRestore      = $true
    NetworkShare       = 'C:\backup'
    NoSysDbUserObjects = $true
    NoCredentials      = $true
    NoBackupDevices    = $true
    NoEndPoints        = $true
}
		
Start-DbaMigration @startDbaMigrationSplat -Force | Select * | Out-GridView

