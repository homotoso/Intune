# Populate with the App Registration details and Tenant ID
$appid = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
$tenantid = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
$secret = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

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
$accesstokenfinal = ConvertTo-SecureString -String $Token -AsPlainText -Force
 
try {
    # Connect to Microsoft Graph using the secure access token
    Connect-MgGraph -AccessToken $accesstokenfinal -NoWelcome
} catch {
    # If connection fails, output the error message and try with the non-secure token
    Write-Error $_.Exception.Message
    Connect-MgGraph -AccessToken $token -NoWelcome
}

# The name of the device to retrieve information for
$DeviceName = "xxxxxxxxxxxxxxxxxxxxx"

# Retrieve the managed device information from Intune
$IntuneDevice = Get-MgDeviceManagementManagedDevice -Filter "deviceName eq '$DeviceName'"

try {
    # Get the LAPS password for the specified device
    Get-LapsAADPassword -DeviceIds $IntuneDevice.AzureAdDeviceId -IncludePasswords -AsPlainText
} catch {
    # If retrieval fails, output a failure message
    Write-Output "Failed to get LAPS password"
}

# Disconnect from Microsoft Graph
disconnect-mggraph
