<#
    .SYNOPSIS
        Configure Widows JumpBox.

    .DESCRIPTION
        Configure Configure Widows JumpBox.
#>
[CmdletBinding(DefaultParameterSetName = "Standard")]
param(

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
Install-ChocolatyAndPackages {
    
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
           
    Write-Log "choco install -y 7zip.install"
    choco install -y 7zip.install
    
    Write-Log "choco Install Google Chrome"
    choco install -y googlechrome -ignore-checksum

    Write-Log "Enable the Audio service for Windows Server"
    Set-Service Audiosrv -StartupType Automatic
    Start-Service Audiosrv

    Write-Log "Disable ServerManager on Windows Server"
    Get-ScheduledTask -TaskName ServerManager | Disable-ScheduledTask -Verbose
}

try {
 
    Write-Log("clean-up windows apps")
    Remove-WindowsApps $UserName

    try {
        Write-Log "Installing chocolaty and packages"
        Install-ChocolatyAndPackages
    }
    catch {
        # chocolaty is best effort
    }
     
    Write-Log "Complete"

}
catch {
    Write-Error $_
}