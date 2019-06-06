Param(
    #[Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [String]
    $Server #= "SQLAG3PPRD\SQLINST1DEV"
	,
    [String]
    $AzureUrl = ''
)
$DBName = 'Diagnostics'

[reflection.assembly]::LoadWithPartialName("Microsoft.SqlServer.Smo")
$serverobj = new-object ("Microsoft.SqlServer.Management.Smo.Server") $Server



if ($DBName -notin $serverobj.databases.name) {
  $db = New-Object -TypeName Microsoft.SqlServer.Management.Smo.Database -argumentlist $server, $DBName
  $db.Create()
}
#sometimes the download fails so lets pre-prime this to work
$dir = split-path $SCRIPT:MyInvocation.MyCommand.Path -parent
$temp = ([System.IO.Path]::GetTempPath()).TrimEnd("\")
Copy-Item $dir\ola.zip $temp

Install-DbaMaintenanceSolution -SqlServer $Server -Database $DBName -ReplaceExisting  -LogToTable  -Solution 'ALL' -InstallJobs
Install-DbaWhoIsActive -SqlServer $Server -Database $DBName

Find-DbaAgentJob -SQLServer $Server -JobName 'DatabaseBackup -*' | foreach-Object { Remove-DbaAgentJob -Job $_.Name  -ServerInstance $Server }
<#
#Make backup jobs
$BackupTypes = @{
  'Azure'=@{
    'Name' = 'Azure Full'
    'Command' = 'EXECUTE [dbo].[DatabaseBackup] @Databases = ''ALL_DATABASES'', @URL = ''' + $AzureUrl + ''',@Credential = ''luazurebackup'', @BackupType = ''FULL'', @Verify = ''N'',@OverrideBackupPreference = ''N'',  @CheckSum = ''Y'',@Compress = ''Y'', @CopyOnly = ''Y'',@LogToTable = ''Y'';';
    'DatabaseName' = "$DBNAME";
    'SubSystem' = 'TSQL';
  };
  'LocalFull' = @{
    'Name' = 'Full Backup Local Databases';
    'Command' = 'EXECUTE [Diagnostics].dbo.DatabaseBackup @Databases = ''ALL_DATABASES,-AVAILABILITY_GROUP_DATABASES'',
    @BackupType = ''FULL'',	@CopyOnly = ''N'', @Verify = ''Y'', @Compress = ''Y'',
    @ChangeBackupType = ''Y'', @CheckSum = ''Y'', @OverrideBackupPreference = ''N'',
    @LogToTable = ''Y'', @CleanupTime = (2 * 7 * 24), @Execute = ''Y'';';
    'DatabaseName' = "$DBNAME";
    'SubSystem' = 'TSQL';
  };
  'LocalAG' = @{
    'Name' = 'Full Backup AG Databases';
    'Command' = 'EXECUTE [Diagnostics].dbo.DatabaseBackup @Databases = ''AVAILABILITY_GROUP_DATABASES'',
    @BackupType = ''FULL'',	@CopyOnly = ''Y'', @Verify = ''Y'', @Compress = ''Y'',
    @ChangeBackupType = ''Y'', @CheckSum = ''Y'', @OverrideBackupPreference = ''N'',
    @LogToTable = ''Y'', @CleanupTime = (2 * 7 * 24), @Execute = ''Y'';';
    'DatabaseName' = "$DBNAME";
    'SubSystem' = 'TSQL';
  };
}

function MakeStep($JobObect,$typeMake,$StepNumber)
{
  $SQLJobStep = New-Object -TypeName Microsoft.SqlServer.Management.SMO.Agent.JobStep -argumentlist $JobObect, $typeMake.name
  $SQLJobStep.Command = $typeMake.Command;
  $SQLJobStep.DatabaseName = $typeMake.DatabaseName
  $SQLJobStep.SubSystem = $typeMake.SubSystem
  $SQLJobStep.OnSuccessAction = "GoToStep"
  $SQLJobStep.OnSuccessStep=$StepNumber + 1
  $SQLJobStep.OnFailAction = "GoToStep"
  $SQLJobStep.OnFailStep = $StepNumber + 1
  $SQLJobStep.Create();
  Return $SQLJobStep
}
#As this is a new job, we create a new object and then create it. If you look on your SQL instance now you'll see a job without steps, schedules or notifications
$SQLJob = New-Object -TypeName Microsoft.SqlServer.Management.SMO.Agent.Job -argumentlist $serverobj.JobServer, "Backups - Monthly Full with Archive"
$SQLJob.Create()

$jobstepcount = 1;
if ($AzureUrl -ne '')
{
  #Make the Azure job step
  makestep $SQLJob ($BackupTypes.Azure) $jobstepcount;
  $jobstepcount++
}
makestep $SQLJob  $BackupTypes.LocalFull $jobstepcount;
$jobstepcount++
makestep $SQLJob ($BackupTypes.AGFULL) $jobstepcount;
$jobstepcount++

#Now add a schedule to our job to finish it off
$SQLJobSchedule =  New-Object -TypeName Microsoft.SqlServer.Management.SMO.Agent.JobSchedule -argumentlist $SQLJob, "Clean Up Backups Schedule"
$SQLJobSchedule.FrequencyTypes =  [Microsoft.SqlServer.Management.SMO.Agent.FrequencyTypes]::Daily
$SQLJobSchedule.FrequencyInterval = 1

#Need to tell SQL when during the day we want to acutally run it. This is a timespan base on 00:00:00 as the start,
$TimeSpan1 = New-TimeSpan -hours 06 -minutes 00
$SQLJobSchedule.ActiveStartTimeofDay = $TimeSpan1

#Set the job to be active from now
$SQLJobSchedule.ActiveStartDate = get-date
$SQLJobSchedule.create()
#>

##On Prod... Add Azure Path...