$input = Get-Content $triggerInput -Raw
$request =  ConvertFrom-Json -InputObject $input

Write-Output $request
