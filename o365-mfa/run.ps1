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

Function O365-MFA-Exists{
    param([Object] $msoluser)
    return $msoluser | Where-Object {$_.StrongAuthenticationRequirements -like '*'}
}

Function O365-MFA-Reset{
    param([String] $upn)

    $output   = @{}
    $msoluser = Get-MsolUser -UserPrincipalName $upn -ErrorAction SilentlyContinue

    if(O365-MFA-Exists $msoluser){
        Set-MsolUser -UserPrincipalName $upn -StrongAuthenticationMethods @()

        $output.detail = 'Reset completed.'
        $output.status = 1
    }else{
        $output.detail = 'MFA not enabled!'
        $output.status = 3
    }

    return $output
}

Function O365-MFA-Enable{
    param([Object] $upn)

    $output   = @{}
    $msoluser = Get-MsolUser -UserPrincipalName $upn -ErrorAction SilentlyContinue

    if(O365-MFA-Exists $msoluser){
		$output.detail = 'MFA exists!'
        $output.status = 2
    }else{

        $mfobject = New-Object -TypeName Microsoft.Online.Administration.StrongAuthenticationRequirement
        $mfobject.RelyingParty = '*'
        $mfauthenabled = @($mfobject)

        Set-MsolUser -UserPrincipalName $upn -StrongAuthenticationRequirements @($mfauthenabled)

		$output.detail = 'MFA enabled.'
        $output.status = 1
    }

    return $output
}

Function O365-MFA-Disable{
    param([Object] $upn)

    $output   = @{}
    $msoluser = Get-MsolUser -UserPrincipalName $upn -ErrorAction SilentlyContinue

    if(O365-MFA-Exists $msoluser){
        Set-MsolUser -UserPrincipalName $upn -StrongAuthenticationRequirements @()

        $output.detail = 'MFA disabled.'
        $output.status = 1
    }else{
        $output.detail = 'MFA is already disabled!'
        $output.status = 3
    }

    return $output
}

#
# Init         
#
O365-Connect -upn $env:O365_ADMIN_UPN -pwd $env:O365_ADMIN_PWD

#
# Query params           
#

$body = Get-Content $req -Raw -Encoding UTF8 | ConvertFrom-Json
$data = $body.data
$meta = $body.meta
$method = $data.attributes.method

#
# Main
#

if($method -eq 'enable'){
    $r = O365-MFA-Enable -upn $data.attributes.email
}elseif($method -eq 'disable'){
    $r = O365-MFA-Disable -upn $data.attributes.email
}else{
    $r = O365-MFA-Reset -upn $data.attributes.email
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

Out-File -Encoding UTF8 -FilePath $res -inputObject $json