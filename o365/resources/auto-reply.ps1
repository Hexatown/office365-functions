Function O365-AutoReply-Enable{
    param ([String] $upn, [String] $message)

    $output   = @{}
    
    Set-MailboxAutoReplyConfiguration -Identity $upn -AutoReplyState Enabled -ExternalMessage $message -InternalMessage $message

    $output.detail = 'Auto reply enabled.'
    $output.status = 1
    
    return $output
}

Function O365-AutoReply-Disable{
    param ([String] $upn)

    $output   = @{}
    
    Set-MailboxAutoReplyConfiguration -Identity $upn -AutoReplyState Disabled -ExternalMessage '' -InternalMessage ''

    $output.detail = 'Auto reply disabled.'
    $output.status = 2
    
    return $output
}

#
# Main
#

if($action -eq 'enable'){
    $r = O365-AutoReply-Enable -upn $body.email -message $body.message
}elseif($action -eq 'disable'){
    $r = O365-AutoReply-Disable -upn $body.email
}

#
# Output
#

$result = @{}
$result.email = $body.email
$result.message = $body.message
$result.status = $r.status # Status codes (1 = Enabled, 2 = Disabled)
$result.detail = $r.detail

# Print (Output) result
PrintResult -res $res -in $result