if ($_req -eq $null){
    $_res = "$PSScriptRoot\output.json"
    $_req = "$PSScriptRoot\input.json"
}

$req = Get-Content $_req -Raw
$params =  ConvertFrom-Json -InputObject $req
$upn = $params.body.upn

if($upn -eq $null){

    exit;
}


param (
    [Parameter(Mandatory = $true)]
    [string] $upn
)

Function O365-MFA-Exists{
    param
    (
        [Object] $msoluser
    )

    return $msoluser | Where-Object {$_.StrongAuthenticationRequirements -like '*'}
}

Function O365-MFA-Reset{
    param
    (
        [Object] $upn
    )

    $result = @{}


    $msoluser = Get-MsolUser -UserPrincipalName $upn -ErrorAction SilentlyContinue

    if(O365-MFA-Exists $msoluser){
        Set-MsolUser -UserPrincipalName $upn -StrongAuthenticationMethods @()
        $result.message = 'MFA reset'
    }else{
        $result.message = 'MFA is not enabled for this user'
        $result.error = $true
    }

    $json = convertto-json -InputObject $result
    Out-File -Encoding Ascii -FilePath $res -inputObject $json
}

O365-MFA-Reset -upn $upn