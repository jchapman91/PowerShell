Param(
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [String]
    $ServerHost
    ,
    [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
    [String]
    $Server
)


Write-Output "Starting Enabling AG"

## This script requires importing the SQLSERVER Module

import-module SqlServer
import-module dbatools -cmdlet "Enable-DbaAgHadr"

$svccount = $(Get-Service -computer $ServerHost  "ClusSvc" -ea SilentlyContinue).count
if ($svccount -eq 1 ) {
    write-output "Enabling AG"
    Enable-DbaAgHadr -SqlInstance $Server -Force
    get-service -ComputerName $Serverhost "mssql`$$($server.split('\')[1])" | Restart-Service -Force
}
elseif ( $svccount -eq 0 ) {
    Write-Output "No Cluster Service, no AG"
}
else {
    Write-Output "ERROR: Cluster Service odd.... $svccount was not 0 or 1"
}
#Untestable until test
#Using 2 different variables?