#
# Common functions 
#

Function O365-Connect{
    param([String] $upn, [String] $pwd)

    Try{
        $pass = ConvertTo-SecureString $pwd -AsPlainText -Force
        $cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $upn,$pass
        Connect-MSOLService -Credential $cred

        # Check if ImportSession exists
        if (-not (Get-Command Get-Mailbox*) ){
            $sessionOption = New-PSSessionOption -SkipRevocationCheck
            $session = New-PSSession -ConfigurationName 'Microsoft.Exchange' -ConnectionUri 'https://ps.outlook.com/PowerShell-LiveID?PSVersion=3.0' -Credential $Cred -Authentication Basic -AllowRedirection -SessionOption $sessionOption
            Import-PSSession $session -AllowClobber -DisableNameChecking | Out-Null
        }
    }Catch{
        Write-Output $('Message: '+$_.Exception.Message)

        exit
    }
}

Function O365-AutoReply-Enable{
    param ([String] $upn, [String] $message)

    $output   = @{}
    
    Set-MailboxAutoReplyConfiguration -Identity $upn -AutoReplyState Enabled -ExternalMessage $message -InternalMessage $message

    $output.detail = 'Auto reply enabled.'
    $output.status = 1
    
    return $output
}

Function O365-AutoReply-Disable{
    param ([String] $upn)

    $output   = @{}
    
    Set-MailboxAutoReplyConfiguration -Identity $upn -AutoReplyState Disabled -ExternalMessage '' -InternalMessage ''

    $output.detail = 'Auto reply disabled.'
    $output.status = 1
    
    return $output
}

#
# Init         
#
O365-Connect -upn $env:O365_ADMIN_UPN -pwd $env:O365_ADMIN_PWD

#
# Query params           
#

$body = Get-Content $req -Raw | ConvertFrom-Json
$data = $body.data
$meta = $body.meta
$method = $data.attributes.method

#
# Main
#

if($method -eq 'enable'){
    $r = O365-AutoReply-Enable -upn $data.attributes.email -message $data.attributes.message
}elseif($method -eq 'disable'){
    $r = O365-AutoReply-Disable -upn $data.attributes.email
}

#
# Output
#

$result = @{}
$result.uuid = $meta.uuid
$result.RowKey = $meta.uuid
$result.PartitionKey = $data.type
$result.requester = $meta.requester
$result.type = $data.type
$result.email = $data.attributes.email
$result.method = $data.attributes.method
$result.status = $r.status # Status (1 = Created, 2 = Exists, 3 = Not enabled/exists)
$result.detail = $r.detail

$json = ConvertTo-Json -InputObject $result

Write-Output $json

Out-File -Encoding Ascii -FilePath $res -inputObject $json