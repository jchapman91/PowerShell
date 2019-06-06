Param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [String]
    $ServerHost
)

Write-Output "Starting Powerplan"

import-module dbatools -cmdlet "Set-DbaPowerPlan"

Set-DbaPowerPlan -ComputerName $ServerHost

## needs to be verified with DBA Tool on host
## Uses $ServerHost