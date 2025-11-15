# Set up router VM

. "$PSScriptRoot\functions.ps1"

Enable-NetAdapter -Name "Ethernet" -Confirm:$false

Update-PowershellVersion

Set-EthernetInterfaceConfiguration -Interface "Ethernet 2" -IP "10.0.1.1"
Set-EthernetInterfaceConfiguration -Interface "Ethernet 3" -IP "10.0.2.1"

Enable-Firewall

Write-Host "Allow specific inbound ports:" -ForegroundColor Cyan

Write-Host "- Port 80 (HTTP)" -ForegroundColor Cyan
New-NetFirewallRule -DisplayName "Allow HTTP"  -Direction Inbound -Protocol TCP -LocalPort 80  -Action Allow

Write-Host "- Port 443 (HTTPS)" -ForegroundColor Cyan
New-NetFirewallRule -DisplayName "Allow HTTPS" -Direction Inbound -Protocol TCP -LocalPort 443 -Action Allow

Write-Host "- Port 53 (DNS)" -ForegroundColor Cyan
New-NetFirewallRule -DisplayName "Allow DNS TCP" -Direction Inbound -Protocol TCP -LocalPort 53 -Action Allow
New-NetFirewallRule -DisplayName "Allow DNS UDP" -Direction Inbound -Protocol UDP -LocalPort 53 -Action Allow

Write-Host "- Port 1194 (OpenVPN)"
New-NetFirewallRule -DisplayName "OpenVPN UDP 1194" -Direction Inbound -Protocol UDP -LocalPort 1194 -Action Allow

Enable-PortForwarding

Enable-DNS

Enable-VPN
Add-SSTP
Add-OpenVPN "server"

Invoke-RemoteAccessServiceRestart

Disable-NetAdapter -Name "Ethernet" -Confirm:$false

# Invoke-Reboot
