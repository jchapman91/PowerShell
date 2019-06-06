Param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [String] $sqlServer
)

[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | Out-Null
$server = New-Object 'Microsoft.SqlServer.Management.SMO.Server' ($sqlServer)


invoke-sqlcmd -ServerInstance $server -Query "sp_configure 'show advanced options', 1;  
GO 
RECONFIGURE; 
GO 
sp_configure 'Agent XPs', 1; 
GO
RECONFIGURE; 
GO"

## This script has been tested by Jeff 8/3/2018
## Works by passing in 1 Variable, SQLSERVER (Server\Instance)
## $sqlServer
