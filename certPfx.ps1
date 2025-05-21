$certName = "CN=local.host"              
$pfxPath = "D:\certPFX\Cert.pfx" # Path to save the PFX file
$pfxPassword = ConvertTo-SecureString -String "MySafetyPass123" -Force -AsPlainText

# Generate self signed certificate
$cert = New-SelfSignedCertificate `
    -Subject $certName `
    -KeyAlgorithm RSA `
    -KeyLength 2048 `
    -HashAlgorithm SHA256 `
    -CertStoreLocation "Cert:\LocalMachine\My" `
    -NotAfter (Get-Date).AddYears(1) `
    -KeyExportPolicy Exportable

Write-Host "Certificate generated: $cert"

# Export to PFX file
try {
    Export-PfxCertificate `
    -Cert $cert `
    -FilePath $pfxPath `
    -Password $pfxPassword 

    Write-Host "Certificate generated:"
    Write-Host "  - PFX: $pfxPath"
}catch {
    Write-Error "❌ Error generating certificate."
}


