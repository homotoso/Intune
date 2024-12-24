#ADD key turn on hide recommended section
New-ItemProperty -Path HKLM:\Software\Policies\Microsoft\Windows\Explorer -Name 'HideRecommendedSection' -Value '1' -Type DWord -Force
