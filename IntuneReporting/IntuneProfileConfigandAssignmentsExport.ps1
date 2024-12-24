# Populate with the App Registration details and Tenant ID
$appid = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
$tenantid = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
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

# Connect to Microsoft Graph using the secure access token
Connect-MgGraph -AccessToken $accesstokenfinal

# Define the API endpoint for configuration profiles
$configProfilesEndpoint = "https://graph.microsoft.com/v1.0/deviceManagement/deviceConfigurations"
# Define the API endpoint for settings catalogs
$settingsCatalogsEndpoint = "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies"

# Function to fetch all pages
function Get-AllPages($uri) {
    $results = @()
    do {
        # Fetch the response from the given URI
        $response = Invoke-MgGraphRequest -Uri $uri -Method Get -Headers $headers
        # Add the response value to the results array
        $results += $response.value
        # Update the URI to the next page, if available
        $uri = $response.'@odata.nextLink'
    } while ($uri)
    return $results
}

# Get all configuration profiles
$profiles = Get-AllPages -uri $configProfilesEndpoint

# Get all settings catalogs
$settingsCatalogs = Get-AllPages -uri $settingsCatalogsEndpoint

# Initialize arrays to store results
$results = @()

# Get assignments for each configuration profile
foreach ($profile in $profiles) {
    # Define the endpoint to get assignments for the profile
    $assignmentsEndpoint = "https://graph.microsoft.com/v1.0/deviceManagement/deviceConfigurations/$($profile.id)/assignments"
    # Fetch the assignments
    $assignments = Invoke-MgGraphRequest -Uri $assignmentsEndpoint -Method Get -Headers $headers
    # Create a custom object to store profile details and assignments
    $profileDetails = [PSCustomObject]@{
        Name        = $profile.displayName
        Id          = $profile.id
        Source      = "Configuration Profile"
        Assignments = ($assignments.value | ForEach-Object {
            if ($_.target.'@odata.type' -eq "#microsoft.graph.allDevicesAssignmentTarget") {
                "All Devices"
            } elseif ($_.target.'@odata.type' -eq "#microsoft.graph.allLicensedUsersAssignmentTarget") {
                "All Users"
            } else {
                # Fetch group details for the specific group ID
                $groupDetails = Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/v1.0/groups/$($_.target.groupId)" -Method Get -Headers $headers
                $groupDetails.displayName
            }
        }) -join ", "
    }
    # Add the profile details to the results array
    $results += $profileDetails
}

# Get assignments for each settings catalog
foreach ($catalog in $settingsCatalogs) {
    # Define the endpoint to get assignments for the catalog
    $assignmentsEndpoint = "https://graph.microsoft.com/beta/deviceManagement/configurationPolicies/$($catalog.id)/assignments"
    # Fetch the assignments
    $assignments = Invoke-MgGraphRequest -Uri $assignmentsEndpoint -Method Get -Headers $headers
    # Create a custom object to store catalog details and assignments
    $catalogDetails = [PSCustomObject]@{
        Name        = $catalog.name
        Id          = $catalog.id
        Source      = "Settings Catalog"
        Assignments = ($assignments.value | ForEach-Object {
            if ($_.target.'@odata.type' -eq "#microsoft.graph.allDevicesAssignmentTarget") {
                "All Devices"
            } elseif ($_.target.'@odata.type' -eq "#microsoft.graph.allLicensedUsersAssignmentTarget") {
                "All Users"
            } else {
                # Fetch group details for the specific group ID
                $groupDetails = Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/v1.0/groups/$($_.target.groupId)" -Method Get -Headers $headers
                $groupDetails.displayName
            }
        }) -join ", "
    }
    # Add the catalog details to the results array
    $results += $catalogDetails
}

# Export the results to a CSV file
$results | Export-Csv -Path "IntuneConfigurationsAndSettingsprod.csv" -NoTypeInformation

# Output a message indicating the completion of the process
Write-Output "Configuration profiles and settings catalogs have been exported to IntuneConfigurationsAndSettings.csv."
