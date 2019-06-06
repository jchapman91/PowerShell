#Change value of following variables as needed
$ServerList = "C:\Users\gtchapman\server_test.txt"
$OutputFile = "C:\Users\gtchapman\output.htm"
 
If (Test-Path $OutputFile){
	Remove-Item $OutputFile
}
 
$emlist="pjayaram@appvion.com,prashanth@abc.com"
$MailServer='sqlshackmail.mail.com'
 
$HTML = '<style type="text/css">
#Header{font-family:"Trebuchet MS", Arial, Helvetica, sans-serif;width:100%;border-collapse:collapse;}
#Header td, #Header th {font-size:14px;border:1px solid #98bf21;padding:3px 7px 2px 7px;}
#Header th {font-size:14px;text-align:left;padding-top:5px;padding-bottom:4px;background-color:#A23942;color:#fff;}
#Header tr.alt td {color:#000;background-color:#EAF2D3;}
</Style>'
$HTML += "<HTML><BODY><Table border=1 cellpadding=0 cellspacing=0 width=100% id=Header>
  <TR>
   <TH><B>ServerName Name</B></TH>
   <TH><B>Database Name</B></TH>
   <TH><B>RecoveryModel</B></TD>
   <TH><B>Last Full Backup Date</B></TH>
   <TH><B>Last Differential Backup Date</B></TH>
   <TH><B>Last Log Backup Date</B></TH>
   </TR>"
 
try {
If (Get-Module SQLServer -ListAvailable) 
{
    Write-Verbose "Preferred SQLServer module found"
    
} 
else
{
Install-Module -Name SqlServer 
 }
} catch {
    Write-Host "Check the Module and version"
}
 
 
Import-Csv $ServerList |ForEach-Object {
$ServerName=$_.ServerName
$SQLServer = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $ServerName 
 Foreach($Database in $SQLServer.Databases)
{
    $DaysSince = ((Get-Date) - $Database.LastBackupDate).Days
    $DaysSinceDiff = ((Get-Date) - $Database.LastDifferentialBackupDate).Days
    $DaysSinceLog = ((Get-Date) - $Database.LastLogBackupDate).TotalHours
     
    IF(($Database.Name) -ne 'tempdb' -and ($Database.Name) -ne 'model')
    {
        if ($Database.RecoveryModel -like "simple" )
        {
            $HTML += "<TR >
                 <TD>$($SQLServer)</TD>
                 <TD>$($Database.Name)</TD>
                 <TD>$($Database.RecoveryModel)</TD>"
 
            if ($DaysSince -gt 7) 
            {
              $HTML += "<TD bgcolor='RED'>$($Database.LastBackupDate)</TD>"
            }
            else
            {
             $HTML += "<TD>$($Database.LastBackupDate)</TD>"
            }
            if ($DaysSinceDiff -gt 1)
            {
               
             $HTML += "<TD bgcolor='CYAN'>$($Database.LastDifferentialBackupDate)</TD>"
            }
            else
            {
             $HTML += "<TD>$($Database.LastDifferentialBackupDate)</TD>"
            }
              $HTML += "<TD>NA</TD></TR>"
            }
            
        }
        if ($Database.RecoveryModel -like "full" )
        {
         $HTML += "<TR >
                 <TD>$($SQLServer)</TD>
                 <TD>$($Database.Name)</TD>
                 <TD>$($Database.RecoveryModel)</TD>"
            if ($DaysSince -gt 7) 
            {
              $HTML += "<TD bgcolor='RED'>$($Database.LastBackupDate)</TD>"
            }
            else
            {
             $HTML += "<TD>$($Database.LastBackupDate)</TD>"
            }
            if ($DaysSinceDiff -gt 1)
            {
               $HTML +="<TD bgcolor='CYAN'>$($Database.LastDifferentialBackupDate)</TD>"
            }
            else
            {
             $HTML += "<TD>$($Database.LastDifferentialBackupDate)</TD>"
            }
 
            if($DaysSinceLog -gt 1)
           {
               $HTML +="<TD bgcolor='Yellow'>$($Database.LastLogBackupDate)</TD>"
            }
            else
            {
             $HTML += "<TD>$($Database.LastLogBackupDate)</TD>"
            }
 
 
            
        }
    }
}
 
 
$HTML += "</Table></BODY></HTML>"
$HTML | Out-File $OutputFile
 
Function sendEmail  
 
{ 
param($from,$to,$subject,$smtphost,$htmlFileName)  
 
$body = Get-Content $htmlFileName 
$body = New-Object System.Net.Mail.MailMessage $from, "$to", $subject, $body 
$body.isBodyhtml = $true
$smtpServer = $MailServer
$smtp = new-object Net.Mail.SmtpClient($smtpServer)
$smtp.Send($body)
 
}  
$date = ( get-date ).ToString('yyyy/MM/dd')
sendEmail pjayaram@appletonideas.com $emlist "Database Backup Report - $Date" $MailServer $OutputFile