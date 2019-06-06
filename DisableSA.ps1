Param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [String] $sqlServer
)

[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | Out-Null
$server = New-Object 'Microsoft.SqlServer.Management.SMO.Server' ($sqlServer)

invoke-sqlcmd -ServerInstance $server -Query "ALTER LOGIN sa DISABLE;"