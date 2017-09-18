#
# Common functions 
#

Function O365-Connect{
    param([String] $upn, [String] $pwd)

    Try{
        $pass = ConvertTo-SecureString $pwd -AsPlainText -Force
        $cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $upn,$pass
        Connect-MSOLService -Credential $cred

        # Check if ImportSession exists
        if (-not (Get-Command Get-Mailbox*) ){
            $sessionOption = New-PSSessionOption -SkipRevocationCheck
            $session = New-PSSession -ConfigurationName 'Microsoft.Exchange' -ConnectionUri 'https://ps.outlook.com/PowerShell-LiveID?PSVersion=3.0' -Credential $Cred -Authentication Basic -AllowRedirection -SessionOption $sessionOption
            Import-PSSession $session -AllowClobber -DisableNameChecking | Out-Null
        }
    }Catch{
        Write-Output $('Message: '+$_.Exception.Message)

        exit
    }
}

Function O365-Distribution-List-Create{
    param([String] $upn, [String] $name, [String] $owner)

    $output     = @{}
    $upnSplit   = $upn.split('@')
    $upnAlias   = $upnSplit[0]
    $upnDomain  = $upnSplit[1]

    # Check if DL already exists
    $exists = Get-DistributionGroup -Identity ($upn) -ErrorAction SilentlyContinue
    if($exists -ne $null){
        $output.detail = 'DL exists!'
        $output.status = '2'

        return $output
    }

    $dist = New-DistributionGroup -Alias ($upnAlias) -DisplayName ($name) -ManagedBy $owner -PrimarySmtpAddress $upn -CopyOwnerToMember -Name ($upn)

    $output.detail = 'DL created.'
    $output.status = '1'

    return $output
}
#
# Init         
#
O365-Connect -upn $env:O365_ADMIN_UPN -pwd $env:O365_ADMIN_PWD

#
# Query params           
#

$body = Get-Content $req -Raw -Encoding UTF8 | ConvertFrom-Json
$data = $body.data
$meta = $body.meta

#
# Main
#
$r = O365-Distribution-List-Create -upn $data.attributes.email -name $data.attributes.name -owner $data.attributes.owner

Write-Output $r

#
# Output
#

$result = @{}
$result.uuid = $meta.uuid
$result.RowKey = $meta.uuid
$result.PartitionKey = $data.type
$result.requester = $meta.requester
$result.type = $data.type
$result.name = $data.attributes.name
$result.email = $data.attributes.email
$result.owner = $data.attributes.owner
$result.status = $r.status # Status (1 = Created, 2 = Exists)
$result.detail = $r.detail

$json = ConvertTo-Json -InputObject $result

Write-Output $json

Out-File -Encoding UTF8 -FilePath $res -inputObject $json