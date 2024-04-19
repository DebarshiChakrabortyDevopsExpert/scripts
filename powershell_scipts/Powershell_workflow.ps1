
## Create Bulk virtual Networks
workflow New-VirtualNeworkAzure
{
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory=$true,Position=0)]$RGName,
    [Parameter(Mandatory=$true,Position=1)]$VnetCount,
    [Parameter(Mandatory=$true,Position=2)]$VnetLocation,
    [Parameter(Mandatory=$true,Position=2)]$VnetName
  )
  $Vnets       = 1..$VnetCount
  
    foreach -parallel -throttlelimit 5 ($vnet in $Vnets)
    {   
        $addr_prefix = "10." + $vnet + ".0.0/24"
        $vnet_final  = $VnetName + $vnet
            $VNET=New-AzVirtualNetwork -Name $vnet_final -ResourceGroupName $RGName -Location $VnetLocation -AddressPrefix $addr_prefix -Verbose -AsJob -ErrorAction Continue |Out-file "D:\logs\currentip.txt" -Append 
    }
}

# Authentication credentials
# Connect-AzAccount
# Set-AzContext -Subscription "ff19a5b8-ab83-4fd1-b00b-010252464cac"
New-VirtualNeworkAzure -RGName "asg_testing" -VnetLocation "East US" -VnetCount 5 -VnetName "TestVnet"


## Create virtual machines
workflow New-VirtualMachines
{
  [CmdletBinding()]
  Param (
    [Parameter(Mandatory=$true,Position=0)]$VMName,
    [Parameter(Mandatory=$true,Position=1)]$VMCount,
    [Parameter(Mandatory=$true,Position=2)]$VHDSize
  )
  $VMs = 1..$VMCount
  foreach -parallel ($VM in $VMs)
  {
    New-VM -Name $VMName$VM -MemoryStartupBytes 512MB -NewVHDPath “D:\Hyper-V\Virtual Hard Disks\$VMName$VM.vhdx” -NewVHDSizeBytes $VHDSize
  }
}

New-VirtualMachines -VMName VM -VMCount 50 -VHDSize 15GB