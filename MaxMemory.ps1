Param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [String]
    $Server,
    [Parameter(Mandatory=$false)]
    [int]
    $SizeMB = $null
)

Write-Output "Starting MaxMemory"

import-module dbatools -cmdlet "Test-DbaMaxMemory","Set-DbaMaxMemory","Get-DbaMaxMemory"

if($SizeMB -eq $null)
{
    $currMem = Test-DbaMaxMemory -SqlServer $Server
    if( $currMem.SqlMaxMB -ne $currMem.RecommendedMB )
    { Set-DbaMaxMemory -Sqlserver $Server }
}
else {
    #user defined the size
    $currMem = Get-DbaMaxMemory -SqlServer $Server
    if( $currMem.SqlMaxMB -ne $SizeMB )
    { Set-DbaMaxMemory -Sqlserver $Server -MaxMB $SizeMB }
}

## Tested Good 7/23/2018 JTC
## Uses $Server