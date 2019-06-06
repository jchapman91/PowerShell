Enter-PSSession -ComputerName sqinst04test
get-volume
Exit-PSSession
Enter-PSSession -ComputerName sqlinst04test
New-DbaDbSnapshot -SqlInstance sqlinst04test\sqlinst04test -Database DataCategories
exit-pssession
Clear-Host
Get-ChildItem -Force \\luna03\lusqlprod
Get-ChildItem -Force \\luna03\lusqlprod -Recurse
Get-ChildItem -Path \\luna03\lusqlprod\Scratch\Migrations -Recurse -Include *.trn | Where-Object -FilterScript {($_.LastWriteTime -gt '2019-02-01')}
$text = 'Hello World!' | Out-File $text -FilePath C:\data\text.txt
Move-Item -Path \\fs\Shared\Backups -Destination \\fs2\Backups\archive



@@@@@@@@@@@@@@@@@

$Folder = "C:\Backups"

#delete files older than 30 days
Get-ChildItem $Folder -Recurse -Force -ea 0 |
? {!$_.PsIsContainer -and $_.LastWriteTime -lt (Get-Date).AddDays(-30)} |
ForEach-Object {
   $_ | del -Force
   $_.FullName | Out-File C:\log\deletedbackups.txt -Append
}

#delete empty folders and subfolders if any exist
Get-ChildItem $Folder -Recurse -Force -ea 0 |
? {$_.PsIsContainer -eq $True} |
? {$_.getfiles().count -eq 0} |
ForEach-Object {
    $_ | del -Force
    $_.FullName | Out-File C:\log\deletedbackups.txt -Append
}

@@@@@@@@@@@@@@@@@

Install-Module -Name PSWindowsUpdate
Install-Module PSWindowsUpdate

Get-DbaCmsRegServer -SqlInstance sqlmdw01

Get-DbaServerProtocol -ComputerName sqlag1pprd
Get-DbaServerProtocol -ComputerName sqlag1pprd  | Out-GridView
(Get-DbaServerProtocol -ComputerName sqlag1pprd | Where-Object { $_.DisplayName -eq 'Named Pipes' }).enable()

Clear-Host

@@@@@@@@@@@@@@@@@

$profile | Format-List * -force

# directory where my scripts are stored

$psdir="D:\Documents\Powershell\Scripts\autoload"  

# load all 'autoload' scripts

Get-ChildItem "${psdir}\*.ps1" | %{.$_} 

Write-Host "Custom PowerShell Environment Loaded" 

@@@@@@@@@@@@@@@@@
