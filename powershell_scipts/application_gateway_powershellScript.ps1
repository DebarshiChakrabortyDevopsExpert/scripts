#####################################################################################################################################################################################################################################################################
# Module Name       : application_gateway_powershellScript.ps1
# Author            : Debarshi Chakraborty
# Created Date      : 09/15/2023
# Description       : This is Azure Powershell based script to maintain Application Gateway
#####################################################################################################################################################################################################################################################################



$pscredential = Get-Credential -UserName $Username
Connect-AzAccount -ServicePrincipal -Credential $pscredential -Tenant $TenantID
Set-AzContext -Subscription $SubscriptionID


function New-Application-Gateway-config ($ApplicationGatewayName,$ApplicationGatewayRG,$BackendPoolName,$BackendFQDN,$httpSettingsName,$protocol,$port,$CookieBasedAffinity,$RequestTimeout,$ListnerName
,$ListnerProtocol,$RoutingRuleName,$RoutingRuleType,$RoutingRulePriority,$frontendType){

    try {     
    $app_gateway = Get-AzApplicationGateway -Name $ApplicationGatewayName -ResourceGroupName $ApplicationGatewayRG
    }
    catch{
    Write-Host "$($_.Exception.ToString().Split("-")[0].Split(":")[1].Trim())"
    $app_gateway = $null
    }
    if ( $app_gateway -ne $null)
    {
        Write-Host "The Application gateway"$ApplicationGatewayName"exists"
        
        try{
        Write-Host "Started creating Backend Pool"
        $backendPool  = Add-AzApplicationGatewayBackendAddressPool -ApplicationGateway $app_gateway -Name $BackendPoolName -BackendFqdns $BackendFQDN
        Set-AzApplicationGateway -ApplicationGateway $app_gateway
        Write-Host $BackendPoolName" Backend pool created "
        }
        catch{
        Write-Host "$($_.Exception.ToString().Split("-")[0].Split(":")[1].Trim())"
        }

        try{
        Write-Host "Started creating HTTP Settings"
        $httpSettings = Add-AzApplicationGatewayBackendHttpSetting -Name $httpSettingsName -ApplicationGateway $app_gateway -Protocol $protocol -Port $port -PickHostNameFromBackendAddress `
        -CookieBasedAffinity $CookieBasedAffinity -RequestTimeout $RequestTimeout
        Set-AzApplicationGateway -ApplicationGateway $app_gateway
        Write-Host $httpSettingsName" HTTP settings created "
        }
        catch{
        Write-Host "$($_.Exception.ToString().Split("-")[0].Split(":")[1].Trim())"
        }        

        try{
        Write-Host "Started creating Listner"
        $frontendIPConfiguration = Get-AzApplicationGatewayFrontendIPConfig -ApplicationGateway $app_gateway
        $frontendPort            = Get-AzApplicationGatewayFrontendPort -ApplicationGateway $app_gateway

            if ($frontendType -eq "Public" -and $ListnerProtocol -eq "Http")
            {
            $listner                 = Add-AzApplicationGatewayHttpListener -Name $ListnerName -ApplicationGateway $app_gateway -Protocol $ListnerProtocol -FrontendIPConfiguration $frontendIPConfiguration[0] -FrontendPort $frontendPort[1]
            }

            elseif($frontendType -eq "Public" -and $ListnerProtocol -eq "Https")
            {
            $listner                 = Add-AzApplicationGatewayHttpListener -Name $ListnerName -ApplicationGateway $app_gateway -Protocol $ListnerProtocol -FrontendIPConfiguration $frontendIPConfiguration[0] -FrontendPort $frontendPort[0]
            }

            elseif($frontendType -eq "Private" -and $ListnerProtocol -eq "Http")
            {
            $listner                 = Add-AzApplicationGatewayHttpListener -Name $ListnerName -ApplicationGateway $app_gateway -Protocol $ListnerProtocol -FrontendIPConfiguration $frontendIPConfiguration[1] -FrontendPort $frontendPort[1]
            }

            else
            {
            $listner                 = Add-AzApplicationGatewayHttpListener -Name $ListnerName -ApplicationGateway $app_gateway -Protocol $ListnerProtocol -FrontendIPConfiguration $frontendIPConfiguration[1] -FrontendPort $frontendPort[0]
            }

        Set-AzApplicationGateway -ApplicationGateway $app_gateway
        Write-Host $ListnerName" Listner created "
        }
        catch{
        Write-Host "$($_.Exception.ToString().Split("-")[0].Split(":")[1].Trim())"
        }

        try{
        Write-Host "Started creating Routing Rule"
        $BackendPool          = Get-AzApplicationGatewayBackendAddressPool -Name $BackendPoolName -ApplicationGateway $app_gateway
        $BackendHttpSettings  = Get-AzApplicationGatewayBackendHttpSetting -Name $httpSettingsName -ApplicationGateway $app_gateway
        $BackendPool          = Get-AzApplicationGatewayBackendAddressPool -Name $BackendPoolName -ApplicationGateway $app_gateway
        $Listener             = Get-AzApplicationGatewayHttpListener -Name $ListnerName -ApplicationGateway $app_gateway
        Add-AzApplicationGatewayRequestRoutingRule -Name $RoutingRuleName -RuleType $RoutingRuleType -Priority $RoutingRulePriority -HttpListener $Listener -BackendHttpSettings $BackendHttpSettings -BackendAddressPool $BackendPool -ApplicationGateway $app_gateway
        Set-AzApplicationGateway -ApplicationGateway $app_gateway -ErrorAction SilentlyContinue
        Write-Host $RoutingRuleName" Routing Rule created "
        }
        catch{
        Write-Host "$($_.Exception.ToString().Split("-")[0].Split(":")[1].Trim())"
        }

        Write-Host "The Application gateway configuration for "$ApplicationGatewayName" is Succesfully Completed"
        
    } 

}



function Remove-Application-Gateway-config ($ApplicationGatewayName,$ApplicationGatewayRG,$BackendPoolName,$httpSettingsName,$RoutingRuleName,$ListnerName){

    try {     
    $app_gateway = Get-AzApplicationGateway -Name $ApplicationGatewayName -ResourceGroupName $ApplicationGatewayRG
    }
    catch{
    Write-Host "$($_.Exception.ToString().Split("-")[0].Split(":")[1].Trim())"
    $app_gateway = $null
    }
    if ( $app_gateway -ne $null)
    {
        Write-Host "The Application gateway"$ApplicationGatewayName" exists"

        $httpSettings = Remove-AzApplicationGatewayRequestRoutingRule -ApplicationGateway $app_gateway -Name $RoutingRuleName
        Set-AzApplicationGateway -ApplicationGateway $app_gateway
        Write-Host $RoutingRuleName" Routing Rule Removed "

        $httpSettings = Remove-AzApplicationGatewayHttpListener -ApplicationGateway $app_gateway -Name $ListnerName
        Set-AzApplicationGateway -ApplicationGateway $app_gateway
        Write-Host $ListnerName" Listner Removed "

        $httpSettings = Remove-AzApplicationGatewayBackendHttpSetting -ApplicationGateway $app_gateway -Name $httpSettingsName
        Set-AzApplicationGateway -ApplicationGateway $app_gateway
        Write-Host $httpSettingsName" HTTP settings Removed "

        $backendPool  = Remove-AzApplicationGatewayBackendAddressPool -ApplicationGateway $app_gateway -Name $BackendPoolName
        Set-AzApplicationGateway -ApplicationGateway $app_gateway
        Write-Host $BackendPoolName" Backend pool Removed "



    } 
}


$ApplicationGatewayName             = "agw-org-01"
$ApplicationGatewayRG               = "rg-org-network"
$BackendPoolName                    = "agw-backend-pool-org-02"
$BackendFQDN                        = "contoso1.com"
$httpSettingsName                   = "agw-http-setting-org-02"
$httpSettingsprotocol               = "Http"
$httpSettingsport                   = 80
$httpSettingsCookieBasedAffinity    = "Disabled"
$httpSettingsRequestTimeout         = 30
$ListnerName                        = "agw-http-listener-org-02"
$ListnerProtocol                    = "Http"
$RoutingRuleName                    = "agw-routing-rule-org-02"
$RoutingRuleType                    = "Basic"
$RoutingRulePriority                = 100
$frontendType                       = "Public"


## Create New Application Gateway Configuration
New-Application-Gateway-config -ApplicationGatewayName $ApplicationGatewayName -ApplicationGatewayRG $ApplicationGatewayRG -BackendPoolName $BackendPoolName -BackendFQDN $BackendFQDN `
-httpSettingsName $httpSettingsName -protocol $httpSettingsprotocol -port $httpSettingsport -CookieBasedAffinity $httpSettingsCookieBasedAffinity -RequestTimeout $httpSettingsRequestTimeout `
-ListnerName $ListnerName -ListnerProtocol $ListnerProtocol -RoutingRuleName $RoutingRuleName -RoutingRuleType $RoutingRuleType -RoutingRulePriority $RoutingRulePriority -frontendType $frontendType

## Remove Application Gateway Configuration
Remove-Application-Gateway-config -ApplicationGatewayName $ApplicationGatewayName -ApplicationGatewayRG $ApplicationGatewayRG -BackendPoolName $BackendPoolName -httpSettingsName $httpSettingsName `
-RoutingRuleName $RoutingRuleName -ListnerName $ListnerName

