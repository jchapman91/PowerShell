  Param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [String] $sqlServer,
    [String] $SqlErrorNum = 15
    )

[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | Out-Null
$server = New-Object 'Microsoft.SqlServer.Management.SMO.Server' ($sqlServer)
$server.Settings.NumberOfLogFiles = $SqlErrorNum
$server.Alter()

## $sqlServer