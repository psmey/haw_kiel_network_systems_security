# Set up client VM

. "$PSScriptRoot\functions.ps1"

$interface = "Ethernet 2"
$gateway = "192.168.1.1"

Update-PowershellVersion

Set-EthernetInterfaceConfiguration -Interface $interface -IP "192.168.1.2" -Gateway $gateway

Enable-Firewall

Set-DnsClientServerAddress -InterfaceAlias $interface -ServerAddresses $gateway, "8.8.8.8"
Get-DnsClientServerAddress -InterfaceAlias $interface

# Invoke-Reboot
