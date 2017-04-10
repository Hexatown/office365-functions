
if ($triggerInput -eq $null){
    $out = "$PSScriptRoot\output.json"
    $triggerInput = "$PSScriptRoot\input.json"
}


$input = Get-Content $triggerInput -Raw
$request =  ConvertFrom-Json -InputObject $input

Write-Output $request
