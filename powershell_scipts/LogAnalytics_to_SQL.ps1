function Insert-data-from-law-tosql {
	param (
		$InsertServerName,
		$UserName,
		$Password,
		$InsertDBName,
		$WorkspaceName,
		$ResourceGroupName,
		$kustoQuery
	)
	$checktableexists = "SELECT object_id FROM sys.tables WHERE name = 'logger'"
	$createtable = @"
CREATE TABLE logger(
    timeGenerated VARCHAR(255),
	agentid VARCHAR(64),  
  	resource_id VARCHAR(64),
  	computer VARCHAR(128),
  	namespace VARCHAR(255),
  	PRIMARY KEY(timeGenerated));
"@
	Write-Output "Welcome to Log Analytics Workspace to Azure SQL Database Data Mover"
	$checktablequery = Invoke-Sqlcmd -ServerInstance $InsertServerName -Database $InsertDBName -Username $UserName -Password $Password -Query $checktableexists
	
	if ($querycheckdata -eq $null) {
		Write-Output "Table logger doesnt exists"
		$query = Invoke-Sqlcmd -ServerInstance $InsertServerName -Database $InsertDBName -Username $UserName -Password $Password -Query $createtable
		Write-Output "Table logger created in the Azure SQL Database"
	}
	
	else { 
		Write-Output "Table logger Already exists" 
	}

	## query Log analytics to gather the logs

	$Workspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $ResourceGroupName -Name $WorkspaceName
	$QueryResults = Invoke-AzOperationalInsightsQuery -Workspace $Workspace -Query $kustoQuery
	$logs = $QueryResults.Results

	## insert the logs in the Azure SQL database
	ForEach ($log in $logs) {
		$agent_id = $log.AgentId
		$name = $log.Name
		$computer = $log.Computer
		$namespace = $log.Namespace
		$TimeGenerated = $log.TimeGenerated
		$checkvaluesquery = "Select * from logger where timeGenerated = '$TimeGenerated'"
		$querycheckdata = Invoke-Sqlcmd -ServerInstance $InsertServerName -Database $InsertDBName -Username $UserName -Password $Password -Query $checkvaluesquery
		if ($querycheckdata -eq $null) {
			$insertdata = @"
INSERT INTO logger (timeGenerated,agentid,resource_id,computer,namespace)
VALUES('$TimeGenerated','$agent_id','$name','$computer','$namespace')
"@
			$query = Invoke-Sqlcmd -ServerInstance $InsertServerName -Database $InsertDBName -Username $UserName -Password $Password -Query $insertdata
			$inserted = $TimeGenerated + ' entry inserted in the table logger'
			Write-Output $inserted
		}
		
		else {
			$exists = $TimeGenerated + ' entry in table logger already exists'
			Write-Output $exists
		}
	}

}

## Create a Table in Azure SQL Database 
$InsertServerName = 'debarssagarikadb.database.windows.net'
$UserName = 'debarshi'
$Password = 'Farcry$456@'
$InsertDBName = 'debarshisagarikadb'
$WorkspaceName = 'lawdebarshi'
$ResourceGroupName = 'testterrafy'
$kustoQuery = 'InsightsMetrics| where TimeGenerated > ago(1h)| where Origin == "vm.azm.ms"| where Namespace == "Computer"| where Name == "Heartbeat"'

Insert-data-from-law-tosql -InsertServerName $InsertServerName -UserName $UserName -Password $Password -InsertDBName $InsertDBName -WorkspaceName $WorkspaceName -ResourceGroupName $ResourceGroupName -kustoQuery $kustoQuery  
