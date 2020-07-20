<#
    .DESCRIPTION
        Configure Windows 10 Workstation with Avid MediaWorker/MediaGateway.
#>

[CmdletBinding()]
param (
    [ValidateNotNullOrEmpty()]
    $AvidNEXISClientURL,
    [ValidateNotNullOrEmpty()]
    $GoogleChromeEnterpriseURL,
    [ValidateNotNullOrEmpty()]
    $PuttyURL,
    [ValidateNotNullOrEmpty()]
    $MAMControlServiceURL
)

#Install-Module -Name PSLogging -Confirm:$False
#Import-Module PSLogging -Confirm:$False

#$sScriptVersion = "1.0"

#Log File Info
#$sLogPath = "D:\"
#$sLogName = "install.log"
#$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

# the windows packages we want to remove
$global:AppxPkgs = @(
    "*windowscommunicationsapps*"
    "*windowsstore*"
)

filter Timestamp {"$(Get-Date -Format o): $_"}

function
Write-Log($message) {
    $msg = $message | Timestamp
#    Write-LogInfo -LogPath $sLogFile -Message $msg
}

function
DownloadFileOverHttp($Url, $DestinationPath) {
    $secureProtocols = @()
    $insecureProtocols = @([System.Net.SecurityProtocolType]::SystemDefault, [System.Net.SecurityProtocolType]::Ssl3)

    foreach ($protocol in [System.Enum]::GetValues([System.Net.SecurityProtocolType])) {
        if ($insecureProtocols -notcontains $protocol) {
            $secureProtocols += $protocol
        }
    }
    [System.Net.ServicePointManager]::SecurityProtocol = $secureProtocols

    # make Invoke-WebRequest go fast: https://stackoverflow.com/questions/14202054/why-is-this-powershell-code-invoke-webrequest-getelementsbytagname-so-incred
    $ProgressPreference = "SilentlyContinue"
    Invoke-WebRequest $Url -UseBasicParsing -OutFile $DestinationPath -Verbose
    Write-Log "$DestinationPath updated"
}

function
Remove-WindowsApps($UserPath) {
    ForEach ($app in $global:AppxPkgs) {
        Get-AppxPackage -Name $app | Remove-AppxPackage -ErrorAction SilentlyContinue
    }
    try {
        ForEach ($app in $global:AppxPkgs) {
            Get-AppxPackage -Name $app | Remove-AppxPackage -User $UserPath -ErrorAction SilentlyContinue
        }
    }
    catch {
        # the user may not be created yet, but in case it is we want to remove the app
    }
    
    #Remove-Item "c:\Users\Public\Desktop\Short_survey_to_provide_input_on_this_VM..url"
}

function
Install-Packages {
    Write-Log "Enable the Audio service for Windows Server"
    Set-Service Audiosrv -StartupType Automatic
    Start-Service Audiosrv

    Write-Log "Disable ServerManager on Windows Server"
    Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask -Verbose

    New-LocalGroup -Name "MAM-Admins"
    #New-LocalUser "svc-ipmam" -Password "P4$$word" -FullName "AVID User" -Description "MAM Control Service user account"
    #Add-LocalGroupMember -Group "Administrators" -Member "svc-ipmam"
    #Add-LocalGroupMember -Group "MAM-Admins" -Member "svc-ipmam"
}

function 
Install-NexisClient {
    $NexisDestinationPath = "D:\AzureData\AvidNEXISClient.msi"
  
    DownloadFileOverHttp $AvidNEXISClientURL $NexisDestinationPath
    Start-Process -FilePath $NexisDestinationPath -ArgumentList "/quiet", "/passive", "/norestart" -Wait
}

function 
Install-Putty {
    $PuttyDestinationPath = "D:\AzureData\putty-installer.msi"

    DownloadFileOverHttp $PuttyURL $PuttyDestinationPath
    Start-Process -FilePath $PuttyDestinationPath -ArgumentList "/quiet", "/passive" -Wait
}

function
Install-GoogleChromeEnterprise { 
    $GoogleDestinationPath = "D:\AzureData\googlechromestandaloneenterprise64.msi"
  
    DownloadFileOverHttp $GoogleChromeEnterpriseURL $GoogleDestinationPath
    Start-Process -FilePath $GoogleDestinationPath -ArgumentList "/qb-!" -Wait
}

function
Install-MAMControlService {
    $MAMDestinationPath = "D:\AzureData\MAMControlService.exe"
    
    DownloadFileOverHttp $MAMControlServiceURL $MAMDestinationPath

    mkdir C:\Logs
 
    #Start-Process -FilePath $MAMDestinationPath -ArgumentList "/s", "/x", "/bD:\AzureData\", "/v/qn" -Wait
    #Start-Process -FilePath "D:\AzureData\MAMControlService.msi" -ArgumentList "/quiet", "/passive", "/norestart" -Wait

    #$MAMDestinationPath /S /v"/qb-!" /v"/L*v \"C:\Logs\ControlService_Install.log\"" /V"SERVICE_ACCOUNT_USERNAME=\"DOMAIN\svc-ipmam\"" /V"SERVICE_ACCOUNT_PASSWORD=\"P4$$word\"" /V"GROUPNAME=\"MAM-Admins\"" /V"INSTALLDIR=\"C:\Program Files\Avid\MediaAssetManager\"" /V"MEDIAASSETMANAGERDATA=\"C:\ProgramData\"" /V"LOGDIR=\"C:\ProgramData\Logs\"" /V"IS_NET_API_LOGON_USERNAME=\"DOMAIN\svc-ipmam\"" /V"IS_NET_API_LOGON_PASSWORD=\"P4$$word\"" /V"IS_NET_API_LOGON_GROUPNAME=\"MAM-Admins\""
    #MAMControlService.exe /S /v"/qb-!" /v"/L*v \"C:\Logs\ControlService_Install.log\"" /V"SERVICE_ACCOUNT_USERNAME=\"DOMAIN\svc-ipmam\"" /V"SERVICE_ACCOUNT_PASSWORD=\"P4$$word\"" /V"GROUPNAME=\"MAM-Admins\"" /V"INSTALLDIR=\"C:\Program Files\Avid\MediaAssetManager\"" /V"MEDIAASSETMANAGERDATA=\"C:\ProgramData\"" /V"LOGDIR=\"C:\ProgramData\Logs\"" /V"IS_NET_API_LOGON_USERNAME=\"DOMAIN\svc-ipmam\"" /V"IS_NET_API_LOGON_PASSWORD=\"P4$$word\"" /V"IS_NET_API_LOGON_GROUPNAME=\"MAM-Admins\""
}

try {

  #  Start-Log -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion
    
    $AvidNEXISClientURL=$Env:avid_nexis_client_url
    $GoogleChromeEnterpriseURL=$Env:google_chrome_enterprise_url
    $PuttyURL=$Env:putty_url
    $MAMControlServiceURL=$Env:mam_control_service_url

    Write-Log("clean-up windows apps")
    Remove-WindowsApps $UserName

    Write-Log "Create Download folder"
    mkdir D:\AzureData

    Write-Log "Installing chocolaty and packages"
    Install-Packages

    Write-Log "Call Install-NexisCLient"
    Install-NexisClient

    Write-Log "Call Install-GoogleChromeEnterprise"
    Install-GoogleChromeEnterprise

    Write-Log "Call Install-Putty"
    Install-Putty

    Write-Log "Call Install-MAMControlService"
    Install-MAMControlService

    Write-Log "Cleanup"
    Remove-Item D:\AzureData -Force  -Recurse -ErrorAction SilentlyContinue

#    Stop-Log -LogPath $sLogFile
    
    #Restart-Computer 
}
catch {
    Write-Error $_
}