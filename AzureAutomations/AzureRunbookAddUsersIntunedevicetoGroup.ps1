# Connect to Microsoft Graph using the identity of the logged-in user
Connect-MgGraph -Identity

# Get the group of users
$usersGroup = Get-MgGroup -Filter "DisplayName eq 'MDM - Ring 2 - Testers Users Azure'"

# Get the devices group
#$devicesGroup = Get-AzureADGroup -SearchString "Devices Group"
$devicesGroup = Get-MgGroup -Filter "DisplayName eq 'MDM - Ring 2 - Testers Devices'"

# Get all the users in the users group
$users = Get-MgGroupMemberAsUser -All -GroupId $usersGroup.Id

# Loop through each user and add their primary device to the devices group
foreach ($user in $users) {
    $userId = $user.Id
    $devices = Get-MgDeviceManagementManagedDevice -Filter "Contains(OperatingSystem,'Windows')" | Where-Object UserId -eq "$userId"
          
    foreach ($device in $devices) {
        $Id = $device.AzureADDeviceId        
        $Objects = Get-Mgdevice -Filter "DeviceId eq '$Id'"
        $ObjectId = $Objects.Id
        $devicecheck = Get-MgGroupMemberAsDevice -All -GroupId $devicesGroup.Id | Where-Object Id -eq "$ObjectId"
        
        if ($devicecheck) {  
            Write-Output 'member found - no action needed'
            Write-Output $ObjectId $device.DeviceName
        }  
        else { 
            Write-Output 'member not found - adding below device'
            Write-Output $ObjectId $device.DeviceName
            # Add the device to the devices group
            New-MgGroupMember -GroupId $devicesGroup.Id -DirectoryObjectId $ObjectId
        }         
    }
}
