#DBATools Code
Break 
start-process https://dbatools.io/snowball 
start-process https://dbatools.io/schwifty 
start-process https://dbatools.io/functions/
Get-DbaConfigValue -FullName 'path.dbatoolslogpath' | Invoke-Item 
import-module dbatools
Write-Output "dbatools module successfully loaded" 
function prompt {"PS [$env:username] > "}


