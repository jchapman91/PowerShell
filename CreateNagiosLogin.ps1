## This script requires importing the SQLSERVER Module

## import-module SqlServer

Param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [String] $sqlServer
)

[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | Out-Null
$server = New-Object 'Microsoft.SqlServer.Management.SMO.Server' ($sqlServer)

invoke-sqlcmd -ServerInstance $server -Query "CREATE LOGIN [znagios] WITH PASSWORD = 0x0100E53AF10088FBA946CB250D595CDD51C07CDFC8A2098AB0E5 HASHED,  DEFAULT_DATABASE = [master], CHECK_POLICY = OFF, CHECK_EXPIRATION = OFF
GO
GRANT VIEW SERVER STATE TO [znagios]
GO
USE [msdb]
GO
CREATE USER [znagios] FOR LOGIN [znagios]
GO
ALTER ROLE [db_datareader] ADD MEMBER [znagios]
GO"

## This script has been tested by Jeff 8/3/2018
## Works by passing in 1 Variable, SQLSERVER (Server\Instance)