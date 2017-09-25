Function PrintResult{
    param($res,$in)
    
    $json = ConvertTo-Json -InputObject $in

    Out-File -Encoding UTF8 -FilePath $res -inputObject $json
}