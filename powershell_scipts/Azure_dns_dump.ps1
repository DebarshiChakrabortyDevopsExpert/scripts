Set-AzContext -Subscription xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

$PrivateDNSZones = Get-AzPrivateDnsZone

## Create a header and Array to hold values and export to CSV
$filepath = 'DNSData.csv'
$header   = 'DNSName' , 'DNSIP'
$DNSData  = @()

## Ceate a Table to visualize DNS Entries
$table = New-Object System.Data.DataTable
$table.Columns.Add("DNSName")
$table.Columns.Add("DNSIP")

ForEach ($Zone in $PrivateDNSZones) {
    $Zone.Name
    $Zone.ResourceGroupName
    $Zone.NumberOfVirtualNetworkLinks
    $Records = Get-AzPrivateDnsRecordSet -ZoneName $Zone.Name -RecordType A -ResourceGroupName $Zone.ResourceGroupName
    
    ForEach ($record in $Records) {

        $row = $table.NewRow()
        $row.DNSName = $record.Name+'.'+$record.ZoneName
        $row.DNSIP   = $record.Records[0].Ipv4Address
        $table.Rows.Add($row)

        $rowData = [PSCustomObject]@{
        DNSName  = $record.Name+'.'+$record.ZoneName
        DNSIP    = $record.Records[0].Ipv4Address
        }
        $DNSData += $rowData

    }
}

$table | Format-Table

$DNSData | Export-Csv -Path $filepath -NoTypeInformation -Encoding UTF8

