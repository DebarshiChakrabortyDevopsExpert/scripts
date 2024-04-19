#####################################################################################################################################################################################################################################################################
# Module Name       : application_gateway_azurecliScript.ps1
# Author            : Debarshi Chakraborty
# Created Date      : 09/15/2023
# Description       : This is Azure cli based powershell script to maintain Application Gateway
#####################################################################################################################################################################################################################################################################



function application-gateway-configuration-create ($app_gateway_rg,$app_gateway_name,$backendpoolname,$backend_pool_servers,$frontend_port_name,
$frontend_port_number,$listner_name,$front_end_ip_name,$frontend_port_name,$listner_hostname,$http_settings_name,$http_settings_port,
$http_settings_protocol,$cookiebasedaffinity,$http_settings_timeout,$rule_name,$rule_type,$rule_priority) 

{
  
  $app_gateway    = az network application-gateway show -g $app_gtway_rg -n $app_gateway_name
  
  if ($app_gateway -ne $null)
  { 
    ## Create backend pool  
    if($backendpoolname -ne $null){
    
        $back_end_pool  = az network application-gateway address-pool create --gateway-name $app_gateway_name --name $backendpoolname --resource-group $app_gateway_rg --servers $backend_pool_servers
        
        if(($frontend_port_name -ne $null) -and ($back_end_pool -ne $null)){

            ## Create Frontend port
            $front_end_port = az network application-gateway frontend-port create -g $app_gateway_rg --gateway-name $app_gateway_name -n $frontend_port_name --port $frontend_port_number
            
            if(($listner_name -ne $null) -and ($front_end_port -ne $null) -and ($http_settings_name -ne $null)){

            ## Create Application gateway listener
            $listner        = az network application-gateway http-listener create --name $listner_name --frontend-ip $front_end_ip_name --frontend-port $frontend_port_name --resource-group $app_gateway_rg --gateway-name $app_gateway_name --host-name $listner_hostname
            ## Create Http settings
            $http_settings  = az network application-gateway http-settings create -g $app_gateway_rg --gateway-name $app_gateway_name -n $http_settings_name --port $http_settings_port --protocol $http_settings_protocol --cookie-based-affinity $cookiebasedaffinity --timeout $http_settings_timeout
            
            if(($rule_name -ne $null) -and ($listner -ne $null) -and ($http_settings -ne $null)){
                $rule           = az network application-gateway rule create --gateway-name $app_gateway_name --name $rule_name --resource-group $app_gateway_rg --http-listener $listner_name --rule-type $rule_type --address-pool $backendpoolname --priority $rule_priority --http-settings $http_settings_name
            }
            else{Write-Host "Please Enter the rule name by passing -rule_name <rule name>"}

            }
            else{Write-Host "Please Enter the listner name by passing -listner_name <listner name> and -http_settings_name <http settings name>"}
        }
        else{Write-Host "Please Enter the frontend port name by passing -frontend_port_name <frontend port name>"}
    }
    else{Write-Host "Please Enter the Backend pool name by passing -backendpoolname <Backend pool name>"}
  
  }else{Write-Host "Please Enter a valid name of application gateway"}
    
}


##Delete Configuration of Application Gateway 
##===========================================

function delete-app-gateway-configuration($app_gateway_rg,$app_gateway_name,$rule_name,$http_settings_name,$listner_name,$frontend_port_name,$backendpoolname)
{
        
        if (($rule_name -ne $null) -and ($http_settings_name -ne $null) -and ($listner_name -ne $null) -and ($frontend_port_name -ne $null) -and ($frontend_port_name -ne $null) -and ($backendpoolname -ne $null))
        {
        ## Delete Application Gateway rule
        az network application-gateway rule delete -g $app_gateway_rg --gateway-name $app_gateway_name -n $rule_name
        Start-Sleep -Seconds 30
        Write-Host "The rule "$rule_name" has been deleted"

        ## Delete http settings for Application Gateway
        az network application-gateway http-settings delete -g $app_gateway_rg --gateway-name $app_gateway_name -n $http_settings_name
        Start-Sleep -Seconds 30
        Write-Host "The http settings "$http_settings_name" has been deleted"

        ## Delete listner for Application Gateway
        az network application-gateway http-listener delete -g $app_gateway_rg --gateway-name $app_gateway_name -n $listner_name
        Start-Sleep -Seconds 30
        Write-Host "The http listner "$listner_name" has been deleted"

        ## Delete front end port for Application Gateway
        az network application-gateway frontend-port delete -g $app_gateway_rg --gateway-name $app_gateway_name -n $frontend_port_name
        Start-Sleep -Seconds 50
        Write-Host "The frotend port "$frontend_port_name" has been deleted"

        ## Delete the Application Gateway Backend pool
        az network application-gateway address-pool delete -g $app_gateway_rg --gateway-name $app_gateway_name -n $backendpoolname
        Write-Host "The backend pool "$backendpoolname" has been deleted"
        }

        else {
        Write-Host "The information required to remove configuration is incomplete"
        }
}

## Values of Application Gateway Configurations 
##==============================================

$app_gateway_rg         = "rg-org-network"
$app_gateway_name       = "agw-org-01"
$backendpoolname        = "agw-backend-pool-org-02"
$backend_pool_servers   = "10.0.0.4 10.0.0.9"
$frontend_port_name     = "agw-frontend-port-org-01"
$frontend_port_number   = 8080
$listner_name           = "agw-http-listener-org-02"
$front_end_ip_name      = "agw-frontend-ip-config-org-01"
$listner_hostname       = "www.hostaname.com"
$http_settings_name     = "agw-http-setting-org-02"
$http_settings_port     = 80
$http_settings_protocol = "Http"
$cookiebasedaffinity    = "Disabled"
$http_settings_timeout  = 30
$rule_name              = "agw-routing-rule-org-02"
$rule_type              = "Basic"
$rule_priority          = 100


## Create Application Gateway Configuration
application-gateway-configuration-create -app_gateway_rg $app_gateway_rg -app_gateway_name $app_gateway_name -backendpoolname $backendpoolname -backend_pool_servers $backend_pool_servers -frontend_port_name $frontend_port_name -frontend_port_number $frontend_port_number -listner_name $listner_name -front_end_ip_name $front_end_ip_name -frontend_port_name $frontend_port_name -listner_hostname $listner_hostname -http_settings_name $http_settings_name -http_settings_port $http_settings_port -http_settings_protocol $http_settings_protocol -cookiebasedaffinity $cookiebasedaffinity -http_settings_timeout $http_settings_timeout -rule_name $rule_name -rule_type $rule_type -rule_priority $rule_priority

## Delete Application Gateway Configuration
delete-app-gateway-configuration -app_gateway_rg $app_gateway_rg -app_gateway_name $app_gateway_name -rule_name $rule_name -http_settings_name $http_settings_name -listner_name $listner_name -frontend_port_name $frontend_port_name -backendpoolname $http_settings_name
