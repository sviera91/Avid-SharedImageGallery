<#
    .SYNOPSIS
        Configure Windows 10 Workstation with Avid Media Composer.

    .DESCRIPTION
        Configure Windows 10 Workstation with Avid Media Composer.

        Example command line: .\setupMachine.ps1 Avid Media Composer
#>
[CmdletBinding(DefaultParameterSetName = "Standard")]
param(
    [string]
    [ValidateNotNullOrEmpty()]
    $TeradiciKey,
    [ValidateNotNullOrEmpty()]
    $TeradiciURL
)

# the windows packages we want to remove
$global:AppxPkgs = @(
    "*windowscommunicationsapps*"
    "*windowsstore*"
)

filter Timestamp {"$(Get-Date -Format o): $_"}

function
Write-Log($message) {
    $msg = $message | Timestamp
    Write-Output $msg
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
Install-Teradici {
    
    Set-Location -Path "D:\AzureData"
        
    Write-Log "Downloading Teradici"
    $TeradiciDestinationPath = "D:\AzureData\PCoIP_agent_release_installer_graphic.exe"

    Write-Log $DestinationPath
    DownloadFileOverHttp $TeradiciURL $TeradiciDestinationPath   
    
    Write-Log "Install Teradici"
    Start-Process -FilePath $TeradiciDestinationPath -ArgumentList "/S", "/nopostreboot" -Verb RunAs -Wait
    
    #cd "C:\Program Files (x86)\Teradici\PCoIP Agent"

    #Write-Log "Register Teradici"   
    #& .\pcoip-register-host.ps1 -RegistrationCode $TeradiciKey

    #& .\pcoip-validate-license.ps1

    #Write-Log "Restart Teradici Service" 
    #restart-service -name PCoIPAgent
}

try {
 
    $TeradiciKey=$Env:teradici_key
    $TeradiciURL=$Env:teradici_url

    Write-Log "Create Download folder"
    mkdir D:\AzureData

    Write-Log "Call Install-Teradici"
    Install-Teradici

    Write-Log "Cleanup"
    Remove-Item D:\AzureData -Force  -Recurse -ErrorAction SilentlyContinue
        
    Write-Log "Complete"

    Write-Log "Restart Computer"
    Restart-Computer 
}
catch {
    Write-Error $_
}