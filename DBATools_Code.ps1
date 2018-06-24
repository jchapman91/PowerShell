#DBATools Code
Break 
start-process https://dbatools.io/snowball 
start-process https://dbatools.io/schwifty 
start-process https://dbatools.io/functions/
#Always start .ps1 code w/ this.  It prevents inadvertent running of entire code block!
Break 
Get-DbaConfigValue -FullName 'path.dbatoolslogpath' | Invoke-Item 

