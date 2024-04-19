<#

.DESCRIPTION

Move bunch of VMS from one subscription to another subscription by taking disk snapshot

#>

Param(

    # Variables for source and destination subscription IDs and tenants

    [Parameter(Mandatory = $False)]

    [string]$SourceSubscriptionId = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXx",  # Default Source Subscription ID

    [Parameter(Mandatory = $False)]

    [string]$DestinationSubscriptionId = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXx",  # Default Destination Subscription ID

    [Parameter(Mandatory = $False)]

    [string]$SourceTenant = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXx",  # Default Source Tenant ID

    [Parameter(Mandatory = $False)]

    [string]$DestinationTenant = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXx",  # Default Destination Tenant ID

    [Parameter(Mandatory = $False)]

    [string]$SourceStorageAccount = "sourcestoragemigration",  # Default Destination Storage Account Name

    [Parameter(Mandatory = $False)]

    [string]$SourceStorageAccountRG = "Test-RG1",  # Default Destination Storage Account Resource Group

    [Parameter(Mandatory = $False)]

    [string]$SourceStorageContainer = "snapshot",  # Default Destination Storage Container Name
 
    [Parameter(Mandatory = $False)]

    [string]$DestinationStorageAccount = "snapstorage3",  # Default Destination Storage Account Name

    [Parameter(Mandatory = $False)]

    [string]$DestinationStorageAccountRG = "GE-RG",  # Default Destination Storage Account Resource Group

    [Parameter(Mandatory = $False)]

    [string]$DestinationStorageContainer = "snapshot",  # Default Destination Storage Container Name

    # Set the Shared Access Signature (SAS) expiry duration in seconds

    [Parameter(Mandatory = $False)]

    [string]$sasExpiryDuration = "3600",  # Default SAS Expiry Duration in Seconds

    # Set the type for the Managed Disk (PremiumLRS or StandardLRS)

    #[Parameter(Mandatory = $False)]

    #[string]$sku = "Premium_LRS",  # Default SKU for Managed Disk

    #[Parameter(Mandatory = $False)]

    [string]$DestinationRG = "GE-RG",  # Default Destination Resource Group

    [Parameter(Mandatory = $False)]

    [string]$vnetName = "testADpoc-vnet",  # Default Virtual Network Name

    [Parameter(Mandatory = $False)]

    [string]$subnetName = "default"  # Default Subnet Name

)

# Path to your CSV file

$CSVFilePath = "C:\Users\dnarula004\Desktop\test.csv"

$CurrentVMList = Get-Content -Path $CSVFilePath


# Connect to the Azure account using provided credentials

$ConnectAzure = Connect-AzAccount -Tenant $SourceTenant -SubscriptionID $SourceSubscriptionId
Write-Output "Connected to Source Tenant and subscription $(($ConnectAzure).Context.Subscription.Name) to get all VM Names"

# Get the List of all VM's

$VMDetails = Get-AzVM

#Initialize $i as 0
$i = 0

# Loop through each VM

foreach($VM in $VMDetails)
{

    # Checks if the current VM name ($VM.Name) is not present in the list of existing VMs ($CurrentVMList).

    # Executes the subsequent code block if the current VM is not found in the list.

    if($VM.Name -notin $CurrentVMList)

    {

        #Get the current context of Subscription

        $SubscriptionContext = (Get-AzContext).Subscription.Id

        if($SubscriptionContext -ne $SourceSubscriptionId)

        {
            # Connect to the source Azure account
            Connect-AzAccount -Tenant $SourceTenant -SubscriptionID $SourceSubscriptionId
            Write-Output "Connected to Source Tenant and subscription $(($ConnectAzure).Context.Subscription.Name)"
        }

        # Set parameters for the VM and disk

        $VMName = $VM.Name

        $SnapshotName = $VMName + "snap$i"

        $DiskvhdName = $SnapshotName + ".vhd"
        
        #Stop the current Virtual machine
 
        $StopVM = Stop-AzVM -ResourceGroupName $VM.ResourceGroupName -Name $VM.Name -Force
        Write-Output "Virtual Machine name: $(($VM).Name) is Stopped"
 
        # Retrieve disk details
        
        $diskName = $VM.StorageProfile.OsDisk.Name
 
        $NewdiskName = $SnapshotName + "OsDisk$i"

        $DiskDetail = Get-AzDisk -ResourceGroupName $VM.ResourceGroupName -DiskName $diskName
 
        Write-Output "Disk HyperVGeneration is: $(($DiskDetail).HyperVGeneration)"
 
        # Create a SnapshotConfig

        $SnapshotConfig =  New-AzSnapshotConfig -SourceUri $VM.StorageProfile.OsDisk.ManagedDisk.Id -Location $VM.Location -CreateOption copy

        # Create a snapshot

        $Snapshot = New-AzSnapshot -Snapshot $SnapshotConfig -SnapshotName $SnapshotName -ResourceGroupName $VM.ResourceGroupName
 
        Write-Output "Snapshot name $(($Snapshot).Name) is created"

        # Generate SAS for the snapshot

        $SAS = Grant-AzSnapshotAccess -ResourceGroupName $VM.ResourceGroupName -SnapshotName $SnapshotName -DurationInSecond $sasExpiryDuration -Access Read
 
        # Retrieve storage account ID and keys for the destination

        $StorageAccountID = (Get-AzStorageAccount -ResourceGroupName $SourceStorageAccountRG -Name $SourceStorageAccount).Id

        $SourceStorageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $SourceStorageAccountRG -Name $SourceStorageAccount).Value[0]

        # Create the context of the storage account where the underlying VHD of the managed disk will be copied

        $SourceStorageAccountContext  = New-AzStorageContext –StorageAccountName $SourceStorageAccount -StorageAccountKey $SourceStorageAccountKey

        # Generates a Shared Access Signature (SAS) URI for the destination storage container.

        # The SAS URI grants Read and Write permissions ('rw') to the specified storage container.

        $SourceContainerSASURI = New-AzStorageContainerSASToken -Context $SourceStorageAccountContext -ExpiryTime (Get-Date).AddSeconds($sasExpiryDuration) -FullUri -Name $SourceStorageContainer -Permission rw

        # Uses azcopy to copy data from the SAS-secured snapshot to the specified container.

        # It utilizes the SAS token generated earlier ($SAS.AccessSAS) to enable access to the source data.
        $containername,$Sourcesastokenkey = $SourceContainerSASURI -split "\?"
        $SourcecontainerSASURI = "$containername/$DiskvhdName`?$Sourcesastokenkey"

        ./azcopy.exe copy $SAS.AccessSAS $SourcecontainerSASURI
 
        #Start the current Virtual machine
 
        $StartVM = Start-AzVM -ResourceGroupName $VM.ResourceGroupName -Name $VM.Name
        Write-Output "Virtual Machine name: $(($VM).Name) is Started"
 
 
        # Connect to the destination Azure account

        $ConnectAzure = Connect-AzAccount -Tenant $DestinationTenant -SubscriptionID $DestinationSubscriptionId
        
        Write-Output "Connected to Destination Tenant and subscription $(($ConnectAzure).Context.Subscription.Name)"
 
 
        # Retrieve storage account ID and keys for the destination

        $StorageAccountID = (Get-AzStorageAccount -ResourceGroupName $DestinationStorageAccountRG -Name $DestinationStorageAccount).Id

        $DestStorageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $DestinationStorageAccountRG -Name $DestinationStorageAccount).Value[0]

        # Create the context of the storage account where the underlying VHD of the managed disk will be copied

        $DestStorageAccountContext  = New-AzStorageContext –StorageAccountName $DestinationStorageAccount -StorageAccountKey $DestStorageAccountKey

        # Generates a Shared Access Signature (SAS) URI for the destination storage container.

        # The SAS URI grants Read and Write permissions ('rw') to the specified storage container.

        $DestContainerSASURI = New-AzStorageContainerSASToken -Context $DestStorageAccountContext -ExpiryTime (Get-Date).AddSeconds($sasExpiryDuration) -FullUri -Name $DestinationStorageContainer -Permission rw

        # Uses azcopy to copy data from the SAS-secured snapshot to the specified container.

        # It utilizes the SAS token generated earlier ($SAS.AccessSAS) to enable access to the source data.
        $containername,$Destsastokenkey = $DestContainerSASURI -split "\?"
        $DestContainerSASURI = "$containername/$DiskvhdName`?$Destsastokenkey"

        ./azcopy.exe copy $SourcecontainerSASURI $DestContainerSASURI

        # Get the URI for the copied VHD

        $VhdUri = (Get-AzStorageBlob -Blob $DiskvhdName -Container $DestinationStorageContainer -Context $DestStorageAccountContext).ICloudBlob.uri.AbsoluteUri
        Write-Output "VHD is coppied in Storage account URL: $VhdUri"
 
        # Create disk configuration

        $DiskConfig = New-AzDiskConfig -SkuName $DiskDetail.Sku.Name -Location $VM.Location -DiskSizeGB $DiskDetail.DiskSizeGB -SourceUri $VhdUri -StorageAccountId $StorageAccountID  -CreateOption Import -HyperVGeneration $DiskDetail.HyperVGeneration -Tier $DiskDetail.Tier
 

        # Create Managed disk

        $NewDisk = New-AzDisk -DiskName $NewdiskName -Disk $DiskConfig -ResourceGroupName $DestinationRG 
        Write-Output "New Disk from VDH is created with name: $(($NewDisk).Name)"
 
        # Configure VM settings

        $RebelVMConfig = New-AzVMConfig -VMName $VMName -VMSize $VM.HardwareProfile.VmSize

        $RebelVMConfig = Set-AzVMOSDisk -VM $RebelVMConfig -ManagedDiskId $NewDisk.Id -CreateOption Attach -Windows -DiskSizeInGB $DiskDetail.DiskSizeGB

        # Set up networking for the VM

        $VNet = Get-AzVirtualNetwork -Name $vnetName -ResourceGroupName $DestinationRG

        $Subnet = Get-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $VNet

        $VMNIC = New-AzNetworkInterface -Name "$VMName-nic" -ResourceGroupName $DestinationRG -Location $VM.Location -SubnetId $Subnet[0].Id
        Write-Output "NIC is created with name: $(($VMNIC).Name)"
 
        $RebelVMConfig = Add-AzVMNetworkInterface -VM $RebelVMConfig -Id $VMNIC.Id

        $RebelVMConfig | Set-AzVMBootDiagnostic -Enable -ResourceGroupName $DestinationStorageAccountRG -StorageAccountName $DestinationStorageAccount

        # Create a new VM

        $NewVM = New-AzVM -VM $RebelVMConfig -ResourceGroupName $DestinationRG -Location $VM.Location
        Write-Output "VM SuccessStatus is : $(($NewVM).IsSuccessStatusCode)"

        # Appends the current VM name ($VMName) to the specified CSV file ($CSVFilePath).

        $VMName | Out-File -FilePath $CSVFilePath -Append -Force
 
        # Connect to the source Azure account
        Connect-AzAccount -Tenant $SourceTenant -SubscriptionID $SourceSubscriptionId
        Write-Output "Connected to Source Tenant and subscription $(($ConnectAzure).Context.Subscription.Name)"
 
        #Cancel the export operation
        $RevokeSAS = Revoke-AzSnapshotAccess -ResourceGroupName $VM.ResourceGroupName -SnapshotName $SnapshotName
        Write-Output "Snapshot Export is cancellation is $(($RevokeSAS).Status)"
 
        #incrementing the operator

        $i++; 

    ## Cleanup
    
    ## Mention the destination container , storage context and blob name

    Remove-AzStorageBlob -Container $containerName  -Context $ctx -Blob $blobName

    ## login to source tenant and set the subscription id

    ## Mention the source snapshot rg and snapshot name

    Remove-AzSnapshot -ResourceGroupName $ResourceGroupName -SnapshotName $Name -Force

    ## Mention the source container , storage context and blob name
    Remove-AzStorageBlob -Container $containerName  -Context $ctx -Blob $blobName


    }
    Write-Output "VM name $(($VM).name) already exist in CSV file"



}
