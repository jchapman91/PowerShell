#written by Ingo Karstein, http://ikarstein.wordpress.com
#  v1.1, 10/12/2012
# modified by Preston Cooper 4-27-2015 to modify "Perform Volume Maintenance Tasks" and added elevation from http://stackoverflow.com/questions/7690994/powershell-running-a-command-as-administrator
## <--- Configure here

## Modified by BEU for parameters
# This must be ran from the host

Param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [String] $SerivceAccount
)

# normally defaults "NT Service\MSSQLSERVER"
$pathToFile1 = "c:\temp\secedit.sdb"
$pathToFile2 = "c:\temp\PerformVolumeMaintenanceTasks.txt"
 
## ---> End of Config
 
$accountToAdd = $SerivceAccount
# Get the ID and security principal of the current user account
$myWindowsID = [System.Security.Principal.WindowsIdentity]::GetCurrent();
$myWindowsPrincipal = New-Object System.Security.Principal.WindowsPrincipal($myWindowsID);
 
# Get the security principal for the administrator role
$adminRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator;
 
# Check to see if we are currently running as an administrator
if($myWindowsPrincipal.IsInRole($adminRole))
{
    # We are running as an administrator, so change the title and background colour to indicate this
    $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)";
    $Host.UI.RawUI.BackgroundColor = "DarkBlue";
    Clear-Host;
}else{
    # We are not running as an administrator, so relaunch as administrator
 
    # Create a new process object that starts PowerShell
    $newProcess = New-Object System.Diagnostics.ProcessStartInfo "PowerShell";
 
    # Specify the current script path and name as a parameter with added scope and support for scripts with spaces in it's path
    $newProcess.Arguments = "& '" + $script:MyInvocation.MyCommand.Path + "'"
 
    # Indicate that the process should be elevated
    $newProcess.Verb = "runas";
 
    # Start the new process
    [System.Diagnostics.Process]::Start($newProcess);
 
    # Exit from the current, unelevated, process
    Exit;
}

#Not tested  yet jtc 8/7/2018
 
 
 
 
$sidstr = $null
try {
    $ntprincipal = new-object System.Security.Principal.NTAccount "$accountToAdd"
    $sid = $ntprincipal.Translate([System.Security.Principal.SecurityIdentifier])
    $sidstr = $sid.Value.ToString()
} catch {
    $sidstr = $null
}
 
Write-Host "Account: $($accountToAdd)" -ForegroundColor DarkCyan
 
if( [string]::IsNullOrEmpty($sidstr) ) {
    Write-Host "Account not found!" -ForegroundColor Red
    exit -1
}
 
Write-Host "Account SID: $($sidstr)" -ForegroundColor DarkCyan
 
$tmp = [System.IO.Path]::GetTempFileName()
 
Write-Host "Export current Local Security Policy" -ForegroundColor DarkCyan
secedit.exe /export /cfg "$($tmp)"
 
$c = Get-Content -Path $tmp
 
$currentSetting = ""
 
foreach($s in $c) {
    if( $s -like "SeManageVolumePrivilege*") {
        $x = $s.split("=",[System.StringSplitOptions]::RemoveEmptyEntries)
        $currentSetting = $x[1].Trim()
    }
}
 
if( $currentSetting -notlike "*$($sidstr)*" ) {
    Write-Host "Modify Setting ""Perform Volume Maintenance Tasks""" -ForegroundColor DarkCyan
     
    if( [string]::IsNullOrEmpty($currentSetting) ) {
        $currentSetting = "*$($sidstr)"
    } else {
        $currentSetting = "*$($sidstr),$($currentSetting)"
    }
     
    Write-Host "$currentSetting"
     
    $outfile = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
Revision=1
[Privilege Rights]
SeManageVolumePrivilege = $($currentSetting)
"@
 
    $tmp2 = $pathToFile2
     
     
    Write-Host "Import new settings to Local Security Policy" -ForegroundColor DarkCyan
    $outfile | Set-Content -Path $tmp2 -Encoding Unicode -Force
 
    #notepad.exe $tmp2
    Push-Location (Split-Path $tmp2)
     
    try {
        Write-Host "secedit.exe /configure /db ""secedit.sdb"" /cfg ""$($tmp2)"" /areas USER_RIGHTS " -ForegroundColor DarkCyan
        secedit.exe /configure /db $pathToFile1 /cfg "$($tmp2)" /areas USER_RIGHTS 
         
    } finally { 
        Pop-Location
    }
} else {
    Write-Host "NO ACTIONS REQUIRED! Account already in ""Allow - Perform Volume Maitenance Tasks""" -ForegroundColor DarkCyan
}
 
Write-Host "Done." -ForegroundColor DarkCyan

#GOOD 07/24/2018