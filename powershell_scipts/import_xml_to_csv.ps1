$ResourceGroups    = Select-Xml -Path C:\Users\debar\Desktop\cloudfoundation.xml -XPath '/CloudFoundationManagement/Resources/ResourceGroup/ResourceGroupName' | ForEach-Object { $_.Node.InnerXML }
$Vnetsname         = Select-Xml -Path C:\Users\debar\Desktop\cloudfoundation.xml -XPath '/CloudFoundationManagement/VNets/VNet/VNetName' | ForEach-Object { $_.Node.InnerXML }
$vnetrgname        = Select-Xml -Path C:\Users\debar\Desktop\cloudfoundation.xml -XPath '/CloudFoundationManagement/VNets/VNet/ResourceGroupName' | ForEach-Object { $_.Node.InnerXML }
$vnetlocation      = Select-Xml -Path C:\Users\debar\Desktop\cloudfoundation.xml -XPath '/CloudFoundationManagement/VNets/VNet/Location' | ForEach-Object { $_.Node.InnerXML }
$VNetAddressSpace  = Select-Xml -Path C:\Users\debar\Desktop\cloudfoundation.xml -XPath '/CloudFoundationManagement/VNets/VNet/VNetAddressSpace' | ForEach-Object { $_.Node.InnerXML }
$vnettagsname      = Select-Xml -Path C:\Users\debar\Desktop\cloudfoundation.xml -XPath '/CloudFoundationManagement/VNets/VNet/Tags/Tag/TagName' | ForEach-Object { $_.Node.InnerXML }
$vnettagsvalue     = Select-Xml -Path C:\Users\debar\Desktop\cloudfoundation.xml -XPath '/CloudFoundationManagement/VNets/VNet/Tags/Tag/TagValue' | ForEach-Object { $_.Node.InnerXML }
$subnetsname       = Select-Xml -Path C:\Users\debar\Desktop\cloudfoundation.xml -XPath '/CloudFoundationManagement/VNets/VNet/Subnets/Subnet/SubnetName' | ForEach-Object { $_.Node.InnerXML }
$vnets_for_subnet  = Select-Xml -Path C:\Users\debar\Desktop\cloudfoundation.xml -XPath '/CloudFoundationManagement/VNets/VNet/Subnets/Subnet/VNetName' | ForEach-Object { $_.Node.InnerXML }
$SubnetAddressSpace= Select-Xml -Path C:\Users\debar\Desktop\cloudfoundation.xml -XPath '/CloudFoundationManagement/VNets/VNet/Subnets/Subnet/SubnetAddressSpace' | ForEach-Object { $_.Node.InnerXML }

## Define the hishest count 
$limitResourceGroups = $ResourceGroups.count
$limitVnetsname = $Vnetsname.count
$limitvnetrgname = $vnetrgname.count
$limitvnetlocation = $vnetlocation.count
$limitVNetAddressSpace = $VNetAddressSpace.count
$limitvnettagsname = $vnettagsname.count
$limitvnettagsvalue = $vnettagsvalue.count
$limitsubnetsname = $subnetsname.count
$limitvnets_for_subnet = $vnets_for_subnet.count
$limitSubnetAddressSpace = $SubnetAddressSpace.count

## Find the highest count value based on that we can run the loop to make it ready to insert in csv 
$highestlimit = [array]$limitResourceGroups,$limitVnetsname,$limitvnetrgname,$limitvnetlocation,$limitVNetAddressSpace,$limitvnettagsname,$limitvnettagsvalue,$limitsubnetsname,$limitvnets_for_subnet,$limitSubnetAddressSpace
$limit = ($highestlimit -split ‘ ‘ | measure -Maximum).Maximum


## Use the highest count value to create formatting for csv 
$csv = For ($i = 0; $i -lt $limit; $i++) {
    New-Object -TypeName psobject -Property @{
        'ResourceGroups' = $(If ($ResourceGroups[$i]) { $ResourceGroups[$i] })
        'Vnetsname' = $(If ($Vnetsname[$i]) { $Vnetsname[$i] })
        'vnetrgname' = $(If ($vnetrgname[$i]) { $vnetrgname[$i] })
        'vnetlocation' = $(If ($vnetlocation[$i]) { $vnetlocation[$i] })
        'VNetAddressSpace' = $(If ($VNetAddressSpace[$i]) { $VNetAddressSpace[$i] })
        'vnettagsname' = $(If ($vnettagsname[$i]) { $vnettagsname[$i] })
        'vnettagsvalue' = $(If ($vnettagsvalue[$i]) { $vnettagsvalue[$i] })
        'subnetsname' = $(If ($subnetsname[$i]) { $subnetsname[$i] })
        'vnets_for_subnet' = $(If ($vnets_for_subnet[$i]) { $vnets_for_subnet[$i] })
        'SubnetAddressSpace' = $(If ($SubnetAddressSpace[$i]) { $SubnetAddressSpace[$i] })
    }
}

## Finally insert value injested from xml to csv in proper format
$csv | Export-csv -Path input.csv