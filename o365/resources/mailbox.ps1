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
        $output.status = 3

        return $output
    }

    # Check if mailbox exists
    $mailbox = Get-Mailbox  -Identity  $upn -ErrorAction SilentlyContinue
    if($mailbox -ne $null){
        $output.detail = 'Mailbox already exists!'
        $output.status = 2

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

    $output.detail = 'Mailbox created.'
    $output.status = 1

    return $output
}

#
# Main
#

$r = O365-Mailbox-Create -upn $body.email -name $body.name -owner $body.owner

#
# Output
#

$result = @{}

$result.name = $body.name
$result.email = $body.email
$result.owner = $body.owner
$result.status = $r.status # Status (1 = Created, 2 = Mailbox exists, 3 ACL group exists)
$result.detail = $r.detail

# Print (Output) result
PrintResult -res $res -in $result