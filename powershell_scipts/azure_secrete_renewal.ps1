function SecretRenewalReminder($spnusername,$spnclientsecret,$spntenent){
    
    az login --service-principal --username  $spnusername --password $spnclientsecret --tenant $spntenent --allow-no-subscriptions

    $Secrets   = az ad app credential list --id $spnusername
    $Secretsv2 = $Secrets| ConvertFrom-Json
    $date      = Get-Date -format "yyyy-MM-dd"

    ForEach ($Secret in $Secretsv2){

        $Secret.displayName
        $timespan = New-TimeSpan -Start $date -End $Secret.endDateTime.Substring(0,10)
        $days     = $timespan.Days
        echo "In "$days" days the secret is about to expire"
         
        if($days -ge 30){
            echo "Secret Renewal not required"
        }
        elseif(($days -le 30 ) -and ($days -ge 15 )){
            echo "Renew Secret Quickly it is about to expire"
        }
        elseif($days -lt 1){
            echo "Secret has already expired"
        }
        else
        {
        echo "No Action Needed"
        }

        echo "========================================================================================================================"
    }

}

SecretRenewalReminder -spnusername xxxxxxxxxxxxxxxxxxxxxxx -spnclientsecret xxxxxxxxxxxxxxxxxxxxxxxxx -spntenent xxxxxxxxxxxxxxxxxxxxxxxx