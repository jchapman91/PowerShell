
  Param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [String] $sqlServer,
    [String] $accountName = 'MSSQL Notify',
    [String] $accountDescription = 'Default dbMail Account',
    [String] $originatingAddress = 'MSsqlNotify@liberty.edu',
    [String] $replyToAddress = 'MSsqlNotify@liberty.edu',
    [String] $smtpServer = 'mail.liberty.edu',
    [String] $profileName = 'default',
    [String] $profileDescription = 'Default dbMail profile',
    [String] $oper = 'MSSQL Team'
    )

# Step 2 - Load the SMO assembly and create the server object, connecting to the server.
  [System.Reflection.Assembly]::LoadWithPartialName('Microsoft.SqlServer.SMO') | Out-Null
  $server = New-Object 'Microsoft.SqlServer.Management.SMO.Server' ($sqlServer)

# Step 3 - Configure the SQL Server to enable Database Mail.
  $server.Configuration.DatabaseMailEnabled.ConfigValue = 1
  $server.Configuration.Alter()

# Step 4 - Alter mail system parameters if desired, this is an optional step.
  $server.Mail.ConfigurationValues.Item('LoggingLevel').Value = 1
  $server.Mail.ConfigurationValues.Item('LoggingLevel').Alter()

# Step 5 - Create the mail account. 
# ArgumentList contains the mail service, account name, description, 
# display name and email address.
  $account = New-Object -TypeName Microsoft.SqlServer.Management.SMO.Mail.MailAccount -Argumentlist $server.Mail, $accountName, $accountDescription, $sqlServer, $originatingAddress
  $account.ReplyToAddress = $replyToAddress
  $account.Create()

# Step 6 - Set the mail server now that the account is created.
  $account.MailServers.Item($sqlServer).Rename($smtpServer)
  $account.Alter()

# Step 7 - Create a public default profile. 
# ArgumentList contains the mail service, profile name and description.
  $mailProfile = New-Object -TypeName Microsoft.SqlServer.Management.SMO.Mail.MailProfile -ArgumentList $server.Mail, $profileName, $profileDescription
  $mailProfile.Create()

# Step 8 - Associate the account to the profile and set the profile to public
  $mailProfile.AddAccount($accountName, 0)
  $mailProfile.AddPrincipal('public', 1)
  $mailProfile.Alter()

# Step 9 - Configure the SQL Agent to use dbMail.
  $server.JobServer.AgentMailType = 'DatabaseMail'
  $server.JobServer.DatabaseMailProfile = $profileName
  $server.JobServer.Alter()

# Step 10 - Create operator
  $op = $server.JobServer.Operators[$oper]
  if ($op.Count -gt 0) {
    $op.Drop()                        # The operator already exists, so drop it
  }
  $op = New-Object ('Microsoft.SqlServer.Management.Smo.Agent.Operator') ($server.JobServer,$oper)
  $op.EmailAddress = $originatingAddress
  $op.Create()
  
  
##needs more 7/24/2018 - BEU
#TODO: Create the Agent Operator
#TODO: if already configured it errors but it would be nice to recreate to verify correctness
#$sqlServer
#Not tested  yet jtc 8/7/2018