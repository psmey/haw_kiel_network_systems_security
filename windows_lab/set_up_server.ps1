# Set up server VM

. "$PSScriptRoot\functions.ps1"

Enable-NetAdapter -Name "Ethernet" -Confirm:$false

Update-PowershellVersion

Set-EthernetInterfaceConfiguration -Interface "Ethernet 2" -IP "10.0.2.2" -Gateway "10.0.2.1"

Enable-Firewall

Write-Host "Allow specific inbound ports:" -ForegroundColor Cyan
Write-Host "- Port 80 (HTTP)" -ForegroundColor Cyan
New-NetFirewallRule -DisplayName "Allow HTTP"  -Direction Inbound -Protocol TCP -LocalPort 80  -Action Allow
Write-Host "- Port 443 (HTTPS)" -ForegroundColor Cyan
New-NetFirewallRule -DisplayName "Allow HTTPS" -Direction Inbound -Protocol TCP -LocalPort 443 -Action Allow

Enable-NginxServer

Disable-NetAdapter -Name "Ethernet" -Confirm:$false

# Invoke-Reboot
