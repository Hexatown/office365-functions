if ($bindIn -eq $null){
    $bindIn = "$PSScriptRoot\input.json"
    $bindOut = "$PSScriptRoot\output.json"
}

$input = Get-Content $bindIn -Raw
$params =  ConvertFrom-Json -InputObject $input
$upn = $params.body.upn

if($upn -eq $null){

    exit
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