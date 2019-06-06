  Param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [String] $sqlServer,
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [String] $sqlServerInstance
  )

#load SMO
[System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | Out-Null
#Connect to our SQL Sever Instance:
$SQLSvr = New-Object -TypeName  Microsoft.SQLServer.Management.Smo.Server("$sqlServer\$sqlServerInstance")

#As this is a new job, we create a new object and then create it. If you look on your SQL instance now you'll see a job without steps, schedules or notifications
$SQLJob = New-Object -TypeName Microsoft.SqlServer.Management.SMO.Agent.Job -argumentlist $SQLSvr.JobServer, "SQL Log Clean UP"
$SQLJob.Create()


#Now we add a step to our Job so it will actually do some work. Again as this is a new job step,
$SQLJobStep = New-Object -TypeName Microsoft.SqlServer.Management.SMO.Agent.JobStep -argumentlist $SQLJob, "Clean History"
$SQLJobStep.Command = 'declare @dt datetime;
    select @dt = cast(dateadd(m, -3, CURRENT_TIMESTAMP) as datetime);
    exec msdb.dbo.sp_delete_backuphistory @dt;
    EXEC msdb.dbo.sp_purge_jobhistory @oldest_date=@dt;
    EXECUTE msdb..sp_maintplan_delete_log null,null,@dt;'
$SQLJobStep.DatabaseName = "msdb"


#Now we have multiple steps, we need to tell SQL Server Agent what to do when things succeed or fail
$SQLJobStep.OnSuccessAction = "GoToStep"
$SQLJobStep.OnSuccessStep=2
$SQLJobStep.OnFailAction = "QuitWithFailure"

$SQLJobStep.Create()

#Step 2
$SQLJobStep2 = New-Object -TypeName Microsoft.SqlServer.Management.SMO.Agent.JobStep -argumentlist $SQLJob, "Rotate Logs"
$SQLJobStep2.Command = "exec sp_cycle_errorlog"
$SQLJobStep2.DatabaseName = "master"
$SQLJobStep2.Create()

#Now add a schedule to our job to finish it off
$SQLJobSchedule =  New-Object -TypeName Microsoft.SqlServer.Management.SMO.Agent.JobSchedule -argumentlist $SQLJob, "Clean Up Backups Schedule"

#Need to use the built in types for Frequency, in this case we'll run it every day
$SQLJobSchedule.FrequencyTypes =  [Microsoft.SqlServer.Management.SMO.Agent.FrequencyTypes]::Daily
#As we've picked daily, this will repeat every day
$SQLJobSchedule.FrequencyInterval = 1

#Need to tell SQL when during the day we want to acutally run it. This is a timespan base on 00:00:00 as the start,
$TimeSpan1 = New-TimeSpan -hours 06 -minutes 00
$SQLJobSchedule.ActiveStartTimeofDay = $TimeSpan1

#Set the job to be active from now
$SQLJobSchedule.ActiveStartDate = get-date
$SQLJobSchedule.create()

## Uses $sqlServer
## Uses $sqlServerInstance