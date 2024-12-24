# Populate with the App Registration details and Tenant ID
$appid = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
$tenantid = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
$secret = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'

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

# Retrieve all Intune devices with the specified operating system and enrollment profile
$IntuneDevices = Get-MgDevice -ALL -Filter "OperatingSystem eq 'MacMDM'"| Where-Object EnrollmentProfileName -eq "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# Retrieve all Intune devices with operating systems that start with 'Mac' and TrustType 'AzureAD'
$IntuneDevices = Get-MgDevice -Filter "startswith(OperatingSystem,'Mac')"| Where-Object TrustType -eq "AzureAD"

# Group the Intune devices by DisplayName
$IntuneDeviceGroups = $IntuneDevices | Group-Object -Property DisplayName
# Identify duplicated devices by checking if the count of grouped devices is greater than 1
$duplicatedDevices = $IntuneDeviceGroups | Where-Object {$_.Count -gt 1 }
# Output the groups of duplicated devices
$duplicatedDevices.Group

# Loop through each duplicated device group
foreach($duplicatedDevice in $duplicatedDevices){
    # Identify the newest device entry based on the last sign-in date
    $newestDevice = $duplicatedDevice.Group | Sort-Object -Property ApproximateLastSignInDateTime -Descending | Select-Object -First 1
    Write-Output 'Latest Device Device entry for multiple entries'
    Write-Output $newestDevice.DisplayName 
    Write-Output $newestDevice.ApproximateLastSignInDateTime
    
    # Identify the old devices by skipping the newest device
    $olddevices = $duplicatedDevice.Group | Sort-Object -Property ApproximateLastSignInDateTime -Descending | Select-Object -Skip 1

    # If the count of old devices is less than 3, proceed with deletion
    if ($olddevices.Count -lt 3){
        foreach($oldDevice in $olddevices) {
            Write-Output 'Deleting old Device entry for multiple entries'
            Write-Output $oldDevice.DisplayName 
            Write-Output $oldDevice.ApproximateLastSignInDateTime
            # Remove the old device (commented out for safety)
            #Remove-MgDevice -DeviceId $oldDevice.Id
        }
    }
    else {
        # If there are too many multiple entries, output a message without deletion
        foreach($oldDevice in $olddevices) {
            Write-Output 'Cant delete old Device entry, too many multiple entries'
            Write-Output $oldDevice.DisplayName 
            Write-Output $oldDevice.ApproximateLastSignInDateTime
        }
    }
}
