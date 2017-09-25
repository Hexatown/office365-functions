Function O365-Distribution-List-Create{
    param([String] $upn, [String] $name, [String] $owner)

    $output     = @{}
    $upnSplit   = $upn.split('@')
    $upnAlias   = $upnSplit[0]
    $upnDomain  = $upnSplit[1]

    # Check if DL already exists
    $exists = Get-DistributionGroup -Identity ($upn) -ErrorAction SilentlyContinue
    if($exists -ne $null){
        $output.detail = 'DL exists!'
        $output.status = 2

        return $output
    }

    $dist = New-DistributionGroup -Alias ($upnAlias) -DisplayName ($name) -ManagedBy $owner -PrimarySmtpAddress $upn -CopyOwnerToMember -Name ($upn)

    $output.detail = 'DL created.'
    $output.status = 1

    return $output
}

#
# Main
#
$r = O365-Distribution-List-Create -upn $body.email -name $body.name -owner $body.owner

Write-Output $r

#
# Output
#

$result = @{}
$result.name = $body.name
$result.email = $body.email
$result.owner = $body.owner
$result.status = $r.status # Status (1 = Created, 2 = Exists)
$result.detail = $r.detail

# Print (Output) result
PrintResult -res $res -in $result