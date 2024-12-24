# Populate with the App Registration details and Tenant ID
$appid = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
$tenantid = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
$secret = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

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

# Define the device name and user principal name
$devicename= "xxxxxxxxxxxxxxxxxxxxxxxx"
$UserPrincipalName = "xxxxxxxxxxxxxxxxxxxxxxxxxx"

# Retrieve the Intune managed device using the device name
$IntuneDevice = Get-MgDeviceManagementManagedDevice -Filter "deviceName eq '$devicename'"

# Retrieve the user information using the user principal name
$user = Get-MgUser -All | Where-Object UserPrincipalName -eq "$UserPrincipalName"
$IntuneDeviceId = $IntuneDevice.Id
$userId = $user.Id

# Define the URI for unassigning the user from the Intune managed device
$uri2 = "https://graph.microsoft.com/beta/deviceManagement/managedDevices/$IntuneDeviceId/users/`$ref"
# Define the body of the request with user information
$Body2 = @{ "@odata.id" = "https://graph.microsoft.com/beta/users/$userId" } | ConvertTo-Json
# Define the HTTP method for the request
$Method2 = "DELETE"

try {
    # Send the request to unassign the user from the Intune managed device
    Invoke-MgGraphRequest -Method $Method2 -Uri $uri2 -Body $Body2
    write-output "successfully unassigned user from Intune device "
    Write-Output $IntuneDeviceId
}
catch {
    # Handle errors if the unassignment fails
    if ($IntuneDeviceId) {
        write-output "unable to assign user from Intune Device"
    }
    else {
        write-output "Intune Device doesn't exist"
    }
}

# Retrieve the serial number of the Intune managed device
$serialNumber = $intunedevice.SerialNumber
# Retrieve the Autopilot device identity using the serial number
$autopilotdevice = Get-MgDeviceManagementWindowsAutopilotDeviceIdentity -All | Where-Object SerialNumber -eq "$SerialNumber"
$autopilotdeviceID = $autopilotdevice.Id

# Retrieve the display name of the user
$userDisplayName = $user.DisplayName

# Define the URI for unassigning the user from the Autopilot device
$uri3 = "https://graph.microsoft.com/v1.0/deviceManagement/windowsAutopilotDeviceIdentities/$autopilotdeviceID/unassignUserFromDevice"
# Define the HTTP method for the request
$Method3 = "POST"

try {
    # Send the request to unassign the user from the Autopilot device
    Invoke-MgGraphRequest -Method $Method3 -Uri $uri3 
    write-output "successfully unassigned user from autopilot hash"
    Write-Output $autopilotdeviceID
}
catch {
    # Handle errors if the unassignment fails
    if ($autopilotdeviceID) {
        write-output "unable to assign user from autopilot hash"
    }
    else {
        write-output "autopilot hash doesn't exist"
    }
}
