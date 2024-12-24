# Detect Recommended Section

# Define the registry path
$Path1 = "HKLM:\Software\Policies\Microsoft\Windows\Explorer"
# Define the name of the registry key
$Name1 = "HideRecommendedSection"
# Define the type of the registry key
$Type1 = "REG_DWORD"
# Define the value to check for
$Value = 1

Try {
    # Retrieve the registry value
    $Registry1 = Get-ItemProperty -Path $Path1 -Name $Name1 -ErrorAction Stop | Select-Object -ExpandProperty $Name1
    
    # Check if the registry value matches the expected value
    If ($Registry1 -eq $Value) {
        # If it matches, output "Detected" and exit with code 0 (success)
        Write-Output "Detected"
        Exit 0
    }
    Else {
        # If it does not match, output "Not Detected" and exit with code 1 (failure)
        Write-Output "Not Detected"
        Exit 1
    }
}
Catch {
    # If there is an error (e.g., the registry key does not exist), output "Not Detected" and exit with code 1 (failure)
    Write-Output "Not Detected"
    Exit 1
}
