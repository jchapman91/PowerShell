Break 

#Backup Maylee

#Change SOURCE (Host\Instance) 
$SrcSQLInstance = 'jeff-lenovo\servera';
#Change DESTINATION (Host\Instance)
$DestSQLInstance = "jeff-lenovo\serverb"; 
#CHANGE -NetworkShare DESTINATION (\\netork\share)
Copy-DbaDatabase -verbose -Source $SrcSQLInstance -Destination $DestSQLInstance -AllDatabases -BackupRestore -NetworkShare \\JEFF-LENOVO\Backup;


