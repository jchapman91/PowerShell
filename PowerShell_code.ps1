$env:PSModulePath . split( ';' ) 

https://dbatools.io/snowball/

invoke-item C:\Backup 
 
Restore-DbaDatabase -SqlInstance jeff-lenovo\servera -Path C:\Backup\AdventureWork2012.bak -WithReplace -verbose 
 
start-process https://dbatools.io/snowball 

#Always start .ps1 code w/ this.  It prevents inadvertent running of entire code block!
Break 
 
get-module -name dbatools 
 
invoke-item C:\Backup 
 
Restore-DbaDatabase -SqlInstance jeff-lenovo\servera -Path C:\Backup\AdventureWork2012.bak -WithReplace -verbose 
 
start-process https://dbatools.io/snowball 
 
start-process https://dbatools.io/schwifty 
 
Get-DbaConfigValue -FullName 'path.dbatoolslogpath' | Invoke-Item 
 
New-DbatoolsSupportPackage 
 
Get-DbaTcpPort -SqlServer jeff-lenovo\servera 
Get-DbaConnection -SqlInstance jeff-lenovo\servera 
$env:PSModulePath . split( ';' ) 

https://dbatools.io/snowball/

invoke-item C:\Backup 
 
Restore-DbaDatabase -SqlInstance jeff-lenovo\servera -Path C:\Backup\AdventureWork2012.bak -WithReplace -verbose 
 
start-process https://dbatools.io/snowball 

#Always start .ps1 code w/ this.  It prevents inadvertent running of entire code block!
Break 
 
get-module -name dbatools 
 
invoke-item C:\Backup 
 
Restore-DbaDatabase -SqlInstance jeff-lenovo\servera -Path C:\Backup\AdventureWork2012.bak -WithReplace -verbose 
 
start-process https://dbatools.io/snowball 
 
start-process https://dbatools.io/schwifty 
 
Get-DbaConfigValue -FullName 'path.dbatoolslogpath' | Invoke-Item 
 
New-DbatoolsSupportPackage 
 
Get-DbaTcpPort -SqlServer jeff-lenovo\servera 
Get-DbaConnection -SqlInstance jeff-lenovo\servera 