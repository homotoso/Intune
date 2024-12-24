# Microsoft.Graph.Users
# Microsoft.Graph.DeviceManagement.Enrollment

# Populate with the App Registration details and Tenant ID
$appid = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
$tenantid = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
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
Connect-MgGraph -AccessToken $accesstokenfinal

# Define the serial number of the device and the user principal name
$SerialNumber = "xxxxxxxxxxxxxxxxx"
$UserPrincipalName = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# Retrieve the Autopilot device identity using the serial number
$autopilotdevice = Get-MgDeviceManagementWindowsAutopilotDeviceIdentity -All | Where-Object SerialNumber -eq "$SerialNumber"
$autopilotdeviceID = $autopilotdevice.Id

# Retrieve the user information using the user principal name
$user = Get-MgUser -All | Where-Object UserPrincipalName -eq "$UserPrincipalName"
$userDisplayName = $user.DisplayName

# Define the URI for assigning the user to the Autopilot device
$uri3 = "https://graph.microsoft.com/v1.0/deviceManagement/windowsAutopilotDeviceIdentities/$autopilotdeviceID/assignUserToDevice"
# Define the HTTP method for the request
$Method3 = "POST"

# Define the body of the request with user information
$Body3 = @{ 
    "userPrincipalName" = "$UserPrincipalName"
    "addressableUserName" = "$userDisplayName"
} | ConvertTo-Json

# Send the request to assign the user to the Autopilot device
Invoke-MgGraphRequest -Method $Method3 -Uri $uri3 -Body $Body3
