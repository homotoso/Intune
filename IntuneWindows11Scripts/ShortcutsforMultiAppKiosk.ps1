#Run with admin priviledges
# Add registry entry for Task Manager and location of exe
reg add "HKLM\Software\Microsoft\Windows\CurrentVersion\App Paths\TaskMgr.exe" /d "c:\windows\System32\Taskmgr.exe" /f

# Define programs with their respective paths or URLs
$Programs = @{ 
    'Task Manager' = 'TaskMgr.exe'
    'Copilot' = 'https://copilot.microsoft.com'    
}

# Define icons for the programs
$Icons = @{
    #'ServiceNow' = 'C:\Temp\servicenow_logo_icon_168837.ico'
    'Copilot' = 'C:\Windows\System32\shell32.dll,14' 
}

# Loop through each program
foreach($p in $Programs.Keys) {
    if ($Programs.$p -match '^https?://') {
        # Create a .url file for the URL
        $urlFilePath = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\$p.url"
        $urlContent = "[InternetShortcut]`nURL=$($Programs.$p)`nIconFile=$($Icons.$p.Split(',')[0])`nIconIndex=$($Icons.$p.Split(',')[1])"
        $urlContent | Out-File -FilePath $urlFilePath -Encoding ASCII
    } else {
        # Create a shortcut for an executable
        $WShell = New-Object -comObject WScript.Shell
        $Shortcut = $WShell.CreateShortcut("$env:ProgramData\Microsoft\Windows\Start Menu\Programs\$p.lnk")
        
        # Set the TargetPath to the executable
        $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\$($Programs.$p)"
        $Shortcut.TargetPath = (Get-ItemProperty -Path $regPath -Name '(default)').'(default)'
        
        # Set the icon for the executable shortcut
        if ($Icons.ContainsKey($p)) {
            $Shortcut.IconLocation = $Icons.$p
        }
        
        # Save the shortcut
        $Shortcut.Save()
    }
}
