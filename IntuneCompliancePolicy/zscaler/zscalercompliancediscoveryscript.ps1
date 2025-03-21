$url = Invoke-WebRequest http://ip.zscaler.com/

$checkzscaler = ($URL.ParsedHtml.getElementsByTagName('div') | Where-Object{ $_.className -eq 'headline' }).innertext

$ZScalerStatus = @{"ZScalerStatus" = $checkzscaler}
return $ZScalerStatus | ConvertTo-Json -Compress
