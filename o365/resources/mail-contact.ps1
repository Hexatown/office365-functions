Function O365-MailContact-Create{
    param([String] $upn, [String] $name)

    $output = @{}

    # Check if contact already exists
    $exists = Get-MailContact -Identity ($upn) -ErrorAction SilentlyContinue
    if($exists -ne $null){
        $output.detail = 'Mail contact exists!'
        $output.status = 2

        return $output
    }

    New-MailContact -Name ($name) -ExternalEmailAddress $upn

    $output.detail = 'Mail contact created.'
    $output.status = 1

    return $output
}

#
# Main
#

if($action -eq 'create'){
    $r = O365-MailContact-Create -upn $body.email -name $body.name
}elseif($action -eq 'delete'){
    # Not yet implemented
}


#
# Output
#
$result = @{}
$result.name = $body.name
$result.email = $body.email
$result.status = $r.status # Status (1 = Created, 2 = Exists)
$result.detail = $r.detail

# Print (Output) result
PrintResult -res $res -in $result