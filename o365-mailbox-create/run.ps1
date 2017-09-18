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

Function O365-Mailbox-Permission-Add{
    param([String] $upn, [String] $owner)

	$mbxPermission = Add-MailboxPermission $upn -User $owner -AccessRights FullAccess -AutoMapping $false
	$rcpPermission = Add-RecipientPermission $upn -Trustee $owner -AccessRights SendAs -Confirm:$False
}

Function O365-Mailbox-Create{
    param([String] $upn, [String] $name, [String] $owner)

    $output     = @{}
    $upnSplit   = $upn.split('@')
    $upnAlias   = $upnSplit[0]
    $upnDomain  = $upnSplit[1]

    # Check if SMBACL group already exists
    $smbacl = Get-DistributionGroup -Identity ("smbacl-" + $upnAlias) -ErrorAction SilentlyContinue
    if($smbacl -ne $null){
        $output.detail = 'ACL group already exists!'
        $output.status = '2'
        return $output
    }

    # Check if mailbox exists
    $mailbox = Get-Mailbox  -Identity  $upn -ErrorAction SilentlyContinue
    if($mailbox -ne $null){
        $output.detail = 'Mailbox already exists!'
        $output.status = '2'

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
        # Add quota
        Set-Mailbox $upn -ProhibitSendReceiveQuota 5GB -ProhibitSendQuota 4.75GB -IssueWarningQuota 4.5GB

        # Add permissions to the mailbox
        O365-Mailbox-Permission-Add -upn $upn -owner $owner

        # Add to MemberOf on the maibox
        Add-DistributionGroupMember -Identity $aclgroup.Identity -Member $mbx.Identity -ErrorAction SilentlyContinue
    }

    $output.detail = 'Mailbox created'
    $output.status = '1'

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

#
# Main
#
$r = O365-Mailbox-Create -upn $data.attributes.email -name $data.attributes.name -owner $data.attributes.owner

#
# Output
#

$result = @{}
$result.uuid = $meta.uuid
$result.RowKey = $meta.uuid
$result.PartitionKey = $data.type
$result.requester = $meta.requester
$result.type = $data.type
$result.name = $data.attributes.name
$result.email = $data.attributes.email
$result.owner = $data.attributes.owner
$result.status = $r.status # Status (1 = Created, 2 = Exists)
$result.detail = $r.detail

$json = ConvertTo-Json -InputObject $result

Write-Output $json

Out-File -Encoding UTF8 -FilePath $res -inputObject $json