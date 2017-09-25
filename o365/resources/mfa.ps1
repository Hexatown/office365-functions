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

        $output.detail = 'MFA Reset completed.'
        $output.status = 3
    }else{
        $output.detail = 'MFA not enabled!'
        $output.status = 4
    }

    return $output
}

Function O365-MFA-Enable{
    param([Object] $upn)

    $output   = @{}
    $msoluser = Get-MsolUser -UserPrincipalName $upn -ErrorAction SilentlyContinue

    if(O365-MFA-Exists $msoluser){
		$output.detail = 'MFA is already enabled!'
        $output.status = 4
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
        $output.status = 2
    }else{
        $output.detail = 'MFA is already disabled!'
        $output.status = 4
    }

    return $output
}

#
# Main
#

if($action -eq 'enable'){
    $r = O365-MFA-Enable -upn $body.email
}elseif($action -eq 'disable'){
    $r = O365-MFA-Disable -upn $body.email
}else{
    $r = O365-MFA-Reset -upn $body.email
}

#
# Output
#

$result = @{}
$result.email = $body.email
$result.status = $r.status # Status codes (1 = Enabled, 2 = Disabled, 3 = Reset, 4 = Others (Check description))
$result.detail = $r.detail

# Print (Output) result
PrintResult -res $res -in $result
