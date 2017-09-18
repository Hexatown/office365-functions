Function O365-Connect{
    param([String] $upn, [String] $pwd)

    Try{
        $pass = ConvertTo-SecureString $pwd -AsPlainText -Force
        $cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $upn,$pass
        Connect-MSOLService -Credential $cred

        # Check if ImportSession exists
        if (-not (Get-Command Get-Mailbox*) ){
            $sessionOption = New-PSSessionOption -SkipRevocationCheck
            $session = New-PSSession -ConfigurationName 'Microsoft.Exchange' -ConnectionUri 'https://ps.outlook.com/PowerShell-LiveID?PSVersion=3.0' -Credential $cred -Authentication Basic -AllowRedirection -SessionOption $sessionOption
            Import-PSSession $session -AllowClobber -DisableNameChecking | Out-Null
        }
    }Catch{
        Write-Output $('Message: '+$_.Exception.Message)

        exit
    }
}

#
# Init         
#
O365-Connect -upn $env:O365_ADMIN_UPN -pwd $env:O365_ADMIN_PWD