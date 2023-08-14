# Populate with the App Registration details and Tenant ID
$appid = 'XXXXXXXXXXXXXXXXXXXXXXXXXXX'
$tenantid = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
$secret = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'

$body =  @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $appid
    Client_Secret = $secret
}
 # Variables to authenticate to graph
$connection = Invoke-RestMethod `
    -Uri https://login.microsoftonline.com/$tenantid/oauth2/v2.0/token `
    -Method POST `
    -Body $body

#variable to capture authentication token
$token = $connection.access_token

#variable to convert token to string
 $accesstokenfinal = ConvertTo-SecureString -String $token -AsPlainText -Force

#connect to graph
Connect-MgGraph -AccessToken $accesstokenfinal

#Variable for serial number
$SerialNumber = "XXXXXXXX"
#Variable for GroupTag
$GroupTag = "XXXXXXXXX"
#Query autopilot device identity based on serial number
$autopilotdevice = Get-MgDeviceManagementWindowsAutopilotDeviceIdentity -All| Where-Object SerialNumber -eq "$SerialNumber"
#assign variable for ID
$autopilotdeviceID = $autopilotdevice.Id
#variable for graph url to update autopilot device properties
$uri2 = "https://graph.microsoft.com/v1.0/deviceManagement/windowsAutopilotDeviceIdentities/$autopilotdeviceID/updateDeviceProperties"
#variable for graph request
$Method2 = "POST"
#variable for updating grouptag
$Body2 = @{ "groupTag" = "$GroupTag"} | ConvertTo-Json
#command to update group tag
Invoke-MgGraphRequest -Method $Method2 -uri $uri2 -body $Body2