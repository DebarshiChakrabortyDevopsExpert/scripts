Workflow Started_Stopped
{
    Parallel
    {
        Get-Service | Where-Object -FilterScript {$_.Status -eq "Running"}
        Get-Service | Where-Object -FilterScript {$_.Status -eq "Stopped"}    
    }
    Write-Output "Above mentioned are the list of started and stopped services"
}

Workflow Copy-Files
{
    $files = @("C:\LocalPath\File1.txt","C:\LocalPath\File2.txt","C:\LocalPath\File3.txt")

    ForEach -Parallel -ThrottleLimit 10 ($File in $Files)
    {
        Copy-Item -Path $File -Destination \\NetworkPath
        Write-Output "$File copied."
    }

    Write-Output "All files copied."
}