try {
    # Get the active power plan
    $activePlan = Get-WmiObject -Namespace root\cimv2\power -Class Win32_PowerPlan | Where-Object { $_.ElementName -eq "Balanced" }

    if ($activePlan) {
        # Check if the active plan is truly active
        $isActive = $activePlan.IsActive
        if ($isActive) {
            # If the Balanced power plan is active, output the message and exit with code 0 (success)
            Write-Output "The Balanced power plan is currently active."
            exit 0
        } else {
            # If the Balanced power plan is not active, output the message and exit with code 1 (failure)
            Write-Output "The Balanced power plan is not active."
            exit 1
        }
    } else {
        # If the Balanced power plan is not found, output the message and exit with code 1 (failure)
        Write-Output "The Balanced power plan is not found."
        exit 1
    }
} catch {
    # If an error occurs while checking the power plan, output the error message and exit with code 1 (failure)
    Write-Output "An error occurred while checking the power plan: $_"
    exit 1
}
