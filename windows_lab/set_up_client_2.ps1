# Set up client VM

. "$PSScriptRoot\functions.ps1"

$interface = "Ethernet 2"
$ip = "10.0.1.3"
$gateway = "10.0.1.1"

Enable-NetAdapter -Name "Ethernet" -Confirm:$false

Update-PowershellVersion

Set-EthernetInterfaceConfiguration -Interface $interface -IP $ip -Gateway $gateway

Enable-Firewall

Set-DnsClientServerAddress -InterfaceAlias $interface -ServerAddresses $gateway
Get-DnsClientServerAddress -InterfaceAlias $interface

Add-SSTPConnection $ip
Add-OpenVPN "client2"

Disable-NetAdapter -Name "Ethernet" -Confirm:$false

# Invoke-Reboot
