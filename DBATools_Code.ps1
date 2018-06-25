#DBATools Code
Break 
start-process https://dbatools.io/snowball 
start-process https://dbatools.io/schwifty 
start-process https://dbatools.io/functions/
Get-DbaConfigValue -FullName 'path.dbatoolslogpath' | Invoke-Item 

