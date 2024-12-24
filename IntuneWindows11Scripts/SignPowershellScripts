# Retrieve the first code signing certificate from the local machine's certificate store
$cert = (Get-ChildItem -path Cert:\LocalMachine\MY -CodeSigningCert)[0]

# Output the certificate details to verify the correct certificate is selected
$cert

# Sign the specified PowerShell script with the retrieved certificate
Set-AuthenticodeSignature -FilePath 'C:\Temp\xxxxxxxxxxxxxxxx.ps1' -Certificate $cert
