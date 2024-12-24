# Populate with the App Registration details and Tenant ID
$appid = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
$tenantid = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
$secret = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

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

# Define the serial number of the device
$SerialNumber = "xxxxxxxxxxxxxxxxxxxxxxx"

# Retrieve the Autopilot device identity using the serial number
$autopilotdevice = Get-MgDeviceManagementWindowsAutopilotDeviceIdentity -All | Where-Object SerialNumber -eq "$SerialNumber"
$autopilotdeviceID = $autopilotdevice.Id
$autoppilotAzuredeviceID = $autopilotdevice.AzureActiveDirectoryDeviceId

# Retrieve the Intune managed device using the serial number
$IntuneDevice = Get-MgDeviceManagementManagedDevice -All | Where-Object SerialNumber  -eq "$SerialNumber"
$IntuneDeviceManagedId = $IntuneDevice.Id

# Define the URI for deleting the Intune managed device
$uri5 = "https://graph.microsoft.com/v1.0/deviceManagement/managedDevices/$IntuneDeviceManagedId"
# Define the HTTP method for the request
$Method5 = "DELETE"
if($IntuneDeviceManagedId.count -lt 2){
    try {
        # Send the DELETE request to remove the Intune managed device
        Invoke-MgGraphRequest -Method $Method5 -Uri $uri5
        Write-Output "successfully deleted intune record"
        Write-Output $IntuneDeviceManagedId
    }
    catch {
        # Handle errors if the deletion fails
        if($IntuneDeviceManagedId) {
            Write-Output "Failed to delete Intune Device record"
            Write-Output $IntuneDeviceManagedId
        }
        else {
            Write-Output "Intune Device record doesn't exist"
            Write-Output $IntuneDeviceManagedId
        }
    }
}

# Define the URI for deleting the Autopilot device identity
$uri4 = "https://graph.microsoft.com/v1.0/deviceManagement/windowsAutopilotDeviceIdentities/$autopilotdeviceID"
# Define the HTTP method for the request
$Method4 = "DELETE"
if($autopilotdeviceID.count -lt 2){
    try {
        # Send the DELETE request to remove the Autopilot device identity
        Invoke-MgGraphRequest -Method $Method4 -Uri $uri4  
        Write-Output "successfully deleted autopilot hash record"
        Write-Output $autopilotdeviceID
    }
    catch {
        # Handle errors if the deletion fails
        if($autopilotdeviceID) {
            Write-Output "Failed to delete autopilot hash record"
            Write-Output $autopilotdeviceID
        }
        else {
            Write-Output "autopilot hash record doesn't exist"
            Write-Output $autopilotdeviceID
        }
    }
}

# Retrieve the Azure AD device using the Autopilot Azure device ID
#$AzureDevice = get-mgdevice -all | where-object DeviceID -eq "$autoppilotAzuredeviceID"
$AzureDevice = get-mgdevice -Filter "DeviceID eq '$autoppilotAzuredeviceID'"

# Retrieve the object ID of the Azure AD device
$AzureDeviceObjectID = $AzureDevice.Id
if($AzureDeviceObjectID.count -lt 2){
    try {
        # Remove the Azure AD device using the object ID
        Remove-MgDevice -DeviceId $AzureDeviceObjectID
        Write-Output "successfully deleted azure record"
        Write-Output $AzureDeviceObjectID
    }
    catch {
        # Handle errors if the deletion fails
        if($AzureDeviceObjectID) {
            Write-Output "Failed to delete azure device record"
            Write-Output $AzureDeviceObjectID
        }
        else {
            Write-Output "azure record doesn't exist"
            Write-Output $AzureDeviceObjectID
        }
    }
}
