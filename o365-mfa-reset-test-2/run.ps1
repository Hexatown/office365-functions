# https://david-obrien.net/2016/07/azure-functions-PowerShell/
# https://david-obrien.net/2016/11/azure-functions-byo-powershell-modules/
# http://blog.tyang.org/2016/10/07/using-custom-powershell-modules-in-azure-functions/

if ($req -eq $null){
    $res = "$PSScriptRoot\output.json"
    $req = "$PSScriptRoot\input.json"
}

$requestBody = Get-Content $req -Raw | ConvertFrom-Json
$name = $requestBody.body.upn

Write-Output "Resetting password for $name"