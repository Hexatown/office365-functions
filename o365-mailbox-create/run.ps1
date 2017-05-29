####################
# Params           #
####################

$body = Get-Content $req -Raw | ConvertFrom-Json
$data = $body.data
$meta = $body.meta

####################
# Common functions #
####################

Function O365-Connect{

    param(
        [String] $upn,
        [String] $pwd
    )

	Import-Module MSOnline
    Try{
        # Using SecureString instead

        $pass = ConvertTo-SecureString $pwd -AsPlainText -Force
        #$pass = convertto-securestring -String $secureString
        $cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $upn,$pass
        Connect-MSOLService -Credential $cred

        # Check if ImportSession exists
        if (-not (Get-Command Get-Mailbox*) ){
            $sessionOption = New-PSSessionOption -SkipRevocationCheck
            $session = New-PSSession -ConfigurationName 'Microsoft.Exchange' -ConnectionUri 'https://ps.outlook.com/PowerShell-LiveID?PSVersion=3.0' -Credential $Cred -Authentication Basic -AllowRedirection -SessionOption $sessionOption
            Import-PSSession $session -AllowClobber -DisableNameChecking | Out-Null

            #Enable-PSremoting -force
        }
    }Catch{
        $e = $_.Exception;
        $eMessage = $e.Message
        $eItem = $e.ItemName

        Write-Output '==========================='
		Write-Output 'Error:'
		Write-Output $('Message: '+$eMessage)
		Write-Output $('Item: '+$eItem)
		Write-Output '==========================='

        exit
    }
}

Function O365-Mailbox-Permission-Add{
    param
    (
        [String] $upn,
        [String] $owner
    )

	$mbxPermission = Add-MailboxPermission $upn -User $owner -AccessRights FullAccess -AutoMapping $false
	$rcpPermission = Add-RecipientPermission $upn -Trustee $owner -AccessRights SendAs -Confirm:$False
}

Function O365-Mailbox-Create{
    param
    (
        [String] $upn,
        [String] $name,
        [String] $owner
    )

    $output     = @{}
    $upnSplit   = $upn.split('@')
    $upnAlias   = $upnSplit[0]
    $upnDomain  = $upnSplit[1]

    # Check if SMBACL group already exists
    $smbacl = Get-DistributionGroup -Identity ("smbacl-" + $upnAlias) -ErrorAction SilentlyContinue
    if($smbacl -ne $null){
        $output.detail = 'ACL group already exists!'
        $output.error = $true

        return $output
    }

    # Check if mailbox exists
    $mailbox = Get-Mailbox  -Identity  $upn -ErrorAction SilentlyContinue
    if($mailbox -ne $null){
        $output.detail = 'Mailbox already exists!'
        $output.error = $true

        return $output
    }

    # Create ACL group
    $aclgroup	= New-DistributionGroup `
                            -Alias ("smbacl-" + $upnAlias) `
                            -DisplayName ("Shared Mailbox ACL " + $name) `
                            -ManagedBy $owner `
                            -CopyOwnerToMember `
                            -Name ("smbacl-" + $upn )

    # Create mailbox
    $mbx = New-Mailbox -Name $name -Alias $upnAlias -Shared -ErrorAction SilentlyContinue
    if($mbx -ne $null){
        Write-Output "Not equal null"

        Write-Output $aclgroup.Identity
        Write-Output $mbx.Identity

        # Add quota
        Set-Mailbox $upn -ProhibitSendReceiveQuota 5GB -ProhibitSendQuota 4.75GB -IssueWarningQuota 4.5GB

        # Add permissions to the mailbox
        O365-Mailbox-Permission-Add -upn $upn -owner $owner

        # Add to MemberOf on the maibox
        Add-DistributionGroupMember -Identity $aclgroup.Identity -Member $mbx.Identity -ErrorAction SilentlyContinue

    }else{
        Write-Output $aclgroup.Identity
        Write-Output $mbx.Identity
        Write-Output "Equal null"
    }



    $output.upn = $upn
    $output.alias = $upnAlias
    $output.domain = $upnDomain
    $output.message = 'Mailbox created'

    return $output
}

####################
# Main             #
####################

O365-Connect -upn $env:O365_ADMIN_UPN -secureString $env:O365_ADMIN_PWD
O365-Mailbox-Create -upn $data.attributes.email -name $data.attributes.name -owner $data.attributes.owner


Write-Output $body

$result = @{}
$result.uuid = $meta.uuid
$result.RowKey = $meta.uuid
$result.PartitionKey = $data.type
$result.requester = $meta.requester
$result.type = $data.type
$result.name = $data.attributes.name
$result.email = $data.attributes.email
$result.owner = $data.attributes.owner

$json = ConvertTo-Json -InputObject $result
Write-Output $json

Out-File -Encoding Ascii -FilePath $res -inputObject $json


