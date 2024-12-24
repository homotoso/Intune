# Check for GVLK (Generic Volume License Key) on the system
$CheckForGVLK = Get-WmiObject SoftwareLicensingProduct -Filter "ApplicationID = '55c92734-d682-4d71-983e-d6ec3f16059f' and LicenseStatus = '5'"
# Retrieve the Product Key Channel to verify if it is a volume key
$CheckForGVLK = $CheckForGVLK.ProductKeyChannel

# If the Product Key Channel is 'Volume:GVLK', proceed with retrieving the digital license
if ($CheckForGVLK -eq 'Volume:GVLK') {
    # Retrieve the original product key from the system's BIOS (OEM Digital License)
    $GetDigitalLicence = (Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey
    # Use the retrieved digital license to set the product key
    cscript c:\windows\system32\slmgr.vbs -ipk $GetDigitalLicence
}
