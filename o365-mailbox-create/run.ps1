#
# Init         
#
O365-Connect -upn $env:O365_ADMIN_UPN -secureString $env:O365_ADMIN_PWD

#
# Query params           
#

$body = Get-Content $req -Raw | ConvertFrom-Json
$data = $body.data
$meta = $body.meta

Write-Output $body

$result = @{}
$result.uuid = $meta.uuid
$result.RowKey = $meta.uuid
$result.PartitionKey = $data.type
$result.requester = $meta.requester
$result.type = $data.type
$result.name = $data.attributes.name
$result.email = $data.attributes.email
$result.owner = $data.attributes.owner

$json = ConvertTo-Json -InputObject $result
Write-Output $json

Out-File -Encoding Ascii -FilePath $res -inputObject $json


#
# Common functions 
#

Function O365-Connect{

    param(
        [String] $upn,
        [String] $pwd
    )

	Import-Module MSOnline
    Try{
        # Using SecureString instead

        $pass = ConvertTo-SecureString $pwd -AsPlainText -Force
        #$pass = convertto-securestring -String $secureString
        $cred = New-Object -TypeName System.Management.Automation.PSCredential -argumentlist $upn,$pass
        Connect-MSOLService -Credential $cred

        # Check if ImportSession exists
        if (-not (Get-Command Get-Mailbox*) ){
            $sessionOption = New-PSSessionOption -SkipRevocationCheck
            $session = New-PSSession -ConfigurationName 'Microsoft.Exchange' -ConnectionUri 'https://ps.outlook.com/PowerShell-LiveID?PSVersion=3.0' -Credential $Cred -Authentication Basic -AllowRedirection -SessionOption $sessionOption
            Import-PSSession $session -AllowClobber -DisableNameChecking | Out-Null

            #Enable-PSremoting -force
        }
    }Catch{
        $e = $_.Exception;
        $eMessage = $e.Message
        $eItem = $e.ItemName

        Write-Output '==========================='
		Write-Output 'Error:'
		Write-Output $('Message: '+$eMessage)
		Write-Output $('Item: '+$eItem)
		Write-Output '==========================='

        exit
    }
}