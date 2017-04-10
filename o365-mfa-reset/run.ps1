# https://david-obrien.net/2016/07/azure-functions-PowerShell/
# https://david-obrien.net/2016/11/azure-functions-byo-powershell-modules/
# http://blog.tyang.org/2016/10/07/using-custom-powershell-modules-in-azure-functions/

if ($triggerInput -eq $null){
    $res = "$PSScriptRoot\output.json"
    $triggerInput = "$PSScriptRoot\input.json"
}


$req = Get-Content $triggerInput -Raw
$requestBody =  ConvertFrom-Json -InputObject $req
$name = $requestBody.body.upn

Write-Output "Resetting password for $name"