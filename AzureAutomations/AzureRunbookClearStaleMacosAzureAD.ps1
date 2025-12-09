#connect to mggraph
Connect-MgGraph -identity

#query for mac devices using intne enrollment profile
$IntuneDevices = Get-MgDevice -Filter "OperatingSystem eq 'MacMDM'"| Where-Object EnrollmentProfileName -eq "xxxxxxxxxxxxxxxxxxxxxxxxxxxx"

#group multiple entries by device together by device name
$IntuneDeviceGroups = $IntuneDevices | Group-Object -Property DisplayName
$duplicatedDevices = $IntuneDeviceGroups | Where-Object {$_.Count -gt 1 }

# for each entry find latest entry and delete oldest entry with a threshold of less than 3
foreach($duplicatedDevice in $duplicatedDevices){
$newestDevice = $duplicatedDevice.Group | Sort-Object -Property ApproximateLastSignInDateTime -Descending | Select-Object -First 1
Write-Output 'Latest Device Device entry for multiple entries'
Write-Output $newestDevice.DisplayName 
Write-Output $newestDevice.ApproximateLastSignInDateTime
$olddevices = $duplicatedDevice.Group | Sort-Object -Property ApproximateLastSignInDateTime -Descending | Select-Object -Skip 1

if ($olddevices.Count -lt 3){
foreach($oldDevice in $olddevices)
{

if (![string]::IsNullOrEmpty($oldDevice.ApproximateLastSignInDateTime)){
Write-Output 'Deleting old Device entry for multiple entries'
Write-Output $oldDevice.DisplayName 
Write-Output $oldDevice.ApproximateLastSignInDateTime
Write-Output $oldDevice.Id
Remove-MgDevice -DeviceId $oldDevice.Id
}
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

