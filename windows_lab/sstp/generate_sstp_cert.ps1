$CertCN = "10.0.1.1"
$CertPassword = (ConvertTo-SecureString "Password123" -AsPlainText -Force)
$CurrentFolder = Get-Location
$PfxFile = Join-Path $CurrentFolder "cert.pfx"
$CerFile = Join-Path $CurrentFolder "cert.cer"

Write-Host "Creating self-signed certificate for $CertCN..." -ForegroundColor Cyan
$cert = New-SelfSignedCertificate `
    -DnsName $CertCN `
    -CertStoreLocation "Cert:\CurrentUser\My" `
    -TextExtension @("2.5.29.17={text}IP=10.0.1.1") `
    -KeyExportPolicy Exportable

Write-Host "Exporting PFX for server use: $PfxFile" -ForegroundColor Cyan
Export-PfxCertificate -Cert $cert -FilePath $PfxFile -Password $CertPassword

Write-Host "Exporting CER for clients: $CerFile" -ForegroundColor Cyan
Export-Certificate -Cert $cert -FilePath $CerFile

Write-Host "Certificate generation complete!" -ForegroundColor Green
Write-Host "PFX : $PfxFile"
Write-Host "CER : $CerFile"
