# Populate with the App Registration details and Tenant ID
$appid = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
$tenantid = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
$secret = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

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

# Create a Temporary Access Pass for a user
# Initialize properties for the Temporary Access Pass
$properties = @{}
$properties.isUsableOnce = $True
$properties.startDateTime = '2024-03-20 11:45:00'
# Convert the properties to JSON format
$propertiesJSON = $properties | ConvertTo-Json

# Create the Temporary Access Pass for the user with the specified UserId
New-MgUserAuthenticationTemporaryAccessPassMethod -UserId xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -BodyParameter $propertiesJSON

# Get a user's Temporary Access Pass using the specified UserId
Get-MgUserAuthenticationTemporaryAccessPassMethod -UserId xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
