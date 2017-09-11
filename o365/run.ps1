
#
# Query params and variables        
#

$body = Get-Content $req -Raw -Encoding UTF8 | ConvertFrom-Json
$resource = $req_params_resource
$action = $body.action
$dir = $EXECUTION_CONTEXT_FUNCTIONDIRECTORY

#
# Load init scripts
# - Connect to Office 365
# - Common helpers
#
. $($dir + "\resources\connect.ps1")
. $($dir + "\utils\helpers.ps1")

#
# Dynamically load needed script based on resource name
#
. $($dir + "\resources\" + $resource + ".ps1")