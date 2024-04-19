#####################################################################################################################################################################################################################################################################
# Module Name       : storage_account_creation.ps1
# Author            : Debarshi Chakraborty
# Created Date      : 04/05/2023
# Description       : THIS SCRIPT CAN FIND AN EXISTING STORAGE ACCOUNT AND EXISTING CONTAINER AND SKIP CREATION OF STORAGE ACCOUNT AND CONTAINER 
#                    ,IF IT DOESNT EXISTS IT CREATE STORAGE ACCOUNT WITH PRIVATE ENDPOINT AND CREATES DESIRED CONTAINER WITHIN IT
#####################################################################################################################################################################################################################################################################

function Create-Storage-Account-container($resourceGroupName,$storageAccountName,$location,$storageContainer,$skuname,$privatelinkserviceconnectionname,$privateEndpointName,$virtualNetworkResourceGroupName,$virtualNetworkName,$subnetName,$dnszonename,$DnszoneID,$ipconfigname,$groupID,$PrivateIPAddress) {
   
   # Check if the Storage Account Exists or not
     
     try {     
     $value = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -ErrorAction SilentlyContinue
     }
     catch{
        Write-Host "$($_.Exception.ToString().Split("-")[0].Split(":")[1].Trim())"
        $value = $null
     }

   # Check the $value is null
    
   if ( $value -eq $null) 
    {
       
    try {
        # Create the storage account
        Write-Host "The Storage Account will get created"
        New-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -Location $location -SkuName $skuname -PublicNetworkAccess "Disabled" -AllowBlobPublicAccess $false
        Write-Host "The Storage Account has been succesfully created"
        Write-Host "Creating private endpoint for Azure Storage Account"
        $storageaccount = Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName
        
        # Create Private Endpoint Service connection
        $privateEndpointConnection = New-AzPrivateLinkServiceConnection -Name $privatelinkserviceconnectionname -PrivateLinkServiceId $storageaccount.id -GroupId "blob"
        $vnet                      = Get-AzVirtualNetwork -ResourceGroupName $virtualNetworkResourceGroupName -Name $virtualNetworkName
        $subnet                    = Get-AzVirtualNetworkSubnetConfig -Name $subnetName -VirtualNetwork $vnet
        $ipconfig                  = New-AzPrivateEndpointIpConfiguration -Name $ipconfigname -GroupId $groupID -MemberName $groupID -PrivateIPAddress $PrivateIPAddress 
        
        # Create Private endpoint 
        New-AzPrivateEndpoint -ResourceGroupName $resourceGroupName -Name $privateEndpointName -Location $location -Subnet $subnet -PrivateLinkServiceConnection $privateEndpointConnection -IpConfiguration $ipconfig
        
        # Get the Azure Private dns Zone 
        $zoneconfig = New-AzPrivateDnsZoneConfig -Name $dnszonename -PrivateDnsZoneId $DnszoneID
        
        # Set the private Dns Group for the resource
        Set-AzPrivateDnsZoneGroup -ResourceGroupName $resourceGroupName -PrivateEndpointName $privateEndpointName -Name default -PrivateDnsZoneConfig $zoneconfig
        Write-Host "The Private endpoint for Storage Account is created Succesfully"  
        
        }
    
    catch{
         Write-Host "$($_.Exception.ToString().Split("-")[0].Split(":")[1].Trim())"
        }
    }

    Write-Host "The Storage Account already exists"
    $ctx = New-AzStorageContext -StorageAccountName $storageAccountName -UseConnectedAccount
    
    # Create Storage Account container
     try {     
     $value = Get-AzStorageContainer -Name $storageContainer -Context $ctx -ErrorAction SilentlyContinue
     }
     catch{
        Write-Host "$($_.Exception.ToString().Split("-")[0].Split(":")[1].Trim())"
        $value = $null
     }

    if ( $value -eq $null)
    {
       
    try{
        Write-Host "The Storage Account container will get created"
        New-AzStorageContainer -Name $storageContainer -Context $ctx
        Write-Host "The Storage Account container has been succesfully created"
        }
    
    catch{
        Write-Host "$($_.Exception.ToString().Split("-")[0].Split(":")[1].Trim())"
        }
    }
    Write-Host "The Storage Account Container already exists"
}

## PROD CONFIGURATIONS

$resourceGroupName                  = "rg-org-eus-tf"
$storageAccountName                 = "storgprodeuslatf01"
$location                           = "eusouth"
$skuname                            = "Standard_ZRS"
$storageContainer                   = "terraform-statefile"
$privatelinkserviceconnectionname   = "prisc-strg-la-prod-eus-01"
$location                           = "eusouth"
$virtualNetworkResourceGroupName    = "rg-org-eus-network"
$virtualNetworkName                 = "vnet-org-eus"
$subnetName                         = "snet-org-eus-data"
$privateEndpointName                = "priep-strg-la-prod-eus-01"
$dnszonename                        = "privatelink.blob.core.windows.net"
$DnszoneID                          = "/subscriptions/xxxxxxxxxxxxx/resourceGroups/rg-org-eus-network/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
$ipconfigname                       = "storgprodeuslatf01-ipconfig1"
$groupID                            = "blob"
$PrivateIPAddress                   = "10.18.20.20"


Create-Storage-Account-container -resourceGroupName $resourceGroupName -storageAccountName $storageAccountName -location $location -storageContainer $storageContainer -skuname $skuname -virtualNetworkResourceGroupName $virtualNetworkResourceGroupName -virtualNetworkName $virtualNetworkName -subnetName $subnetName -privatelinkserviceconnectionname $privatelinkserviceconnectionname -privateEndpointName $privateEndpointName -dnszonename $dnszonename -DnszoneID $DnszoneID -ipconfigname $ipconfigname -groupID $groupID -PrivateIPAddress $PrivateIPAddress
