# Populate with the App Registration details and Tenant ID
$appid = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
$tenantid = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
$secret = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

# Generate body to authenticate against Microsoft Graph
$body =  @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $appid
    Client_Secret = $secret
}
 
# Connection variable to get the authentication token
$connection = Invoke-RestMethod `
    -Uri https://login.microsoftonline.com/$tenantid/oauth2/v2.0/token `
    -Method POST `
    -Body $body
 
# Extract the access token from the connection response
$token = $connection.access_token
# Convert the access token to a secure string
$accesstokenfinal = ConvertTo-SecureString -String $token -AsPlainText -Force
# Connect to Microsoft Graph using the secure access token
Connect-MgGraph -AccessToken $accesstokenfinal -nowelcome

# Define the device name
$devicename = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# Retrieve the Intune managed device using the device name
$IntuneDevice = Get-MgDeviceManagementManagedDevice -All | Where-Object DeviceName -eq "$devicename" | Where-Object OperatingSystem -eq "Windows"
$IntuneDeviceManagedId = $IntuneDevice.Id

# Define the URI for wiping the Intune managed device
$uri6 = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/$IntuneDeviceManagedId/wipe"
# Define the HTTP method for the request
$Method6 = "POST"

# Send the request to wipe the Intune managed device
Invoke-MgGraphRequest -Method $Method6 -Uri $uri6
