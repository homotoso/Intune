#connect to mggraph
Connect-MgGraph -identity

#query for mac devices using intUne enrollment profile
$IntuneDevices = Get-MgDevice -Filter "OperatingSystem eq 'MacMDM'"| Where-Object EnrollmentProfileName -eq "XXXXXXXXXXXXXXXXXX"

#group multiple entries that have same display name
$IntuneDeviceGroups = $IntuneDevices | Group-Object -Property DisplayName
$duplicatedDevices = $IntuneDeviceGroups | Where-Object {$_.Count -gt 1 }

# for each Multiple entry with same display name find latest entry and delete oldest entry. Set threshold of less than 4 device object to deleted with same name
foreach($duplicatedDevice in $duplicatedDevices){
#query and set variable for newest device entry withe same same
$newestDevice = $duplicatedDevice.Group | Sort-Object -Property ApproximateLastSignInDateTime -Descending | Select-Object -First 1
Write-Output 'Latest Device Device entry for multiple entries'
Write-Output $newestDevice.DisplayName 
Write-Output $newestDevice.ApproximateLastSignInDateTime
#query and set variable for old devices with same name
$olddevices = $duplicatedDevice.Group | Sort-Object -Property ApproximateLastSignInDateTime -Descending | Select-Object -Skip 1

#if the number of devices with same name is more than 4 dont delete. Stop mass deletion if query captures more devices than expected
if ($olddevices.Count -lt 3){
foreach($oldDevice in $olddevices)
{

Write-Output 'Deleting old Device entry for multiple entries'
Write-Output $oldDevice.DisplayName 
Write-Output $oldDevice.ApproximateLastSignInDateTime
Write-Output $oldDevice.Id
Remove-MgDevice -DeviceId $oldDevice.Id

}
}
else 
{
foreach($oldDevice in $olddevices)
{
Write-Output 'Cant delete old Device entry, too many multiple entries'
Write-Output $oldDevice.DisplayName 
Write-Output $oldDevice.ApproximateLastSignInDateTime
}
}

}

