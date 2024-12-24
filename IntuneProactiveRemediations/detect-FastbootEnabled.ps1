# Define the registry path for the power settings
$Path = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power"
# Define the name of the registry key
$Name = "HiberbootEnabled"
# Define the type of the registry key
$Type = "DWORD"
# Define the value to check for
$Value = 0

Try {
    # Retrieve the registry value
    $Registry = Get-ItemProperty -Path $Path -Name $Name -ErrorAction Stop | Select-Object -ExpandProperty $Name
    # Check if the registry value matches the expected value
    If ($Registry -eq $Value) {
        # If it matches, output "Compliant" and exit with code 0 (success)
        Write-Output "Compliant"
        Exit 0
    } 
    # If it does not match, output "Not Compliant" and exit with code 1 (failure)
    Write-Warning "Not Compliant"
    Exit 1
} 
Catch {
    # If there is an error (e.g., the registry key does not exist), output "Not Compliant" and exit with code 1 (failure)
    Write-Warning "Not Compliant"
    Exit 1
}
