# Helper functions for set up

# Get	Common	Retrieve something
# Set	Common	Change or assign a value
# New	Common	Create something
# Remove	Common	Delete something
# Add	Common	Add something to an existing entity
# Enable	Common	Turn something on
# Disable	Common	Turn something off
# Test	Diagnostic	Verify or validate something
# Invoke	Common	Run an action
# Show	Common	Display something
# Update	Common	Refresh or modify something

function Update-PowershellVersion {
    Write-Host "Install PowerShell 7" -ForegroundColor Cyan
    choco install powershell-core -y

    Write-Host "Add PowerShell 7 folder first" -ForegroundColor Cyan
    setx PATH "C:\Program Files\PowerShell\7;$env:PATH"
}

function Set-EthernetInterfaceConfiguration {
    param (
        [string]$Interface,
        [string]$IP,
        [string]$Gateway # optional
    )

    Write-Host "=== Configuring $($Interface) ===" -ForegroundColor Yellow

    Write-Host "Removing existing IPs..." -ForegroundColor Cyan
    Get-NetIPAddress -InterfaceAlias $Interface -ErrorAction SilentlyContinue `
    | Remove-NetIPAddress -Confirm:$false

    Write-Host "Removing existing default gateway(s)..." -ForegroundColor Cyan
    Get-NetRoute -InterfaceAlias $Interface -DestinationPrefix "0.0.0.0/0" -ErrorAction SilentlyContinue `
    | Remove-NetRoute -Confirm:$false

    if ($null -ne $Gateway -and $Gateway -ne "") {
        Write-Host "Assigning IP $IP/24 with gateway $Gateway" -ForegroundColor Cyan
        New-NetIPAddress -InterfaceAlias $Interface -IPAddress $IP -PrefixLength 24 -DefaultGateway $Gateway
    }
    else {
        Write-Host "Assigning IP $IP/24 (no gateway)" -ForegroundColor Cyan
        New-NetIPAddress -InterfaceAlias $Interface -IPAddress $IP -PrefixLength 24
    }

    Write-Host "Verifying configuration..." -ForegroundColor Cyan
    Get-NetIPConfiguration -InterfaceAlias $Interface `
    | Select-Object InterfaceAlias, IPv4Address, IPv4DefaultGateway `
    | Format-Table

    Write-Host "=== $($Interface) configured successfully ===" -ForegroundColor Green
}

function Enable-PortForwarding {
    Write-Host "=== Configuring port forwarding ===" -ForegroundColor Yellow

    Write-Host "Enable port forwarding for system"  -ForegroundColor Cyan
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" -Name "IPEnableRouter" -Value 1

    Write-Host "Enable port forwarding on interfaces"  -ForegroundColor Cyan
    Set-NetIPInterface -Forwarding Enabled

    Write-Host "Verify port forwarding for network Interfaces"  -ForegroundColor Cyan
    Get-NetIPInterface | Select-Object InterfaceAlias, AddressFamily, Forwarding

    Write-Host "Install dependencies RemoteAccess & Routing"  -ForegroundColor Cyan
    Install-WindowsFeature -Name RemoteAccess, Routing -IncludeManagementTools

    Write-Host "Start RemoteAccess and enable auto-start"  -ForegroundColor Cyan
    Set-Service RemoteAccess -StartupType Automatic
    Start-Service RemoteAccess

    Write-Host "=== Successfully configured port forwarding ===" -ForegroundColor Green
}

function Enable-Firewall {
    Write-Host "=== Set up firewall ===" -ForegroundColor Yellow

    Write-Host "Factory reset firewall" -ForegroundColor Cyan
    netsh advfirewall reset

    Write-Host "Enable firewall" -ForegroundColor Cyan
    Set-NetFirewallProfile -Profile Domain, Private, Public -Enabled True

    # Write-Host "Set up firewall rules" -ForegroundColor Cyan
    # Write-Host "Default inbound: block" -ForegroundColor Cyan
    # Write-Host "Default outbound: allow" -ForegroundColor Cyan
    # Set-NetFirewallProfile -Profile Domain, Private, Public -DefaultInboundAction Block -DefaultOutboundAction Allow

    Get-NetFirewallProfile `
    | Select-Object Name, Enabled, DefaultInboundAction, DefaultOutboundAction `
    | Format-Table

    Write-Host "Enable ping and echo for connectivity test" -ForegroundColor Cyan
    # Enable-NetFirewallRule -DisplayName "File and Printer Sharing (Echo Request - ICMPv4-In)"
    # Enable-NetFirewallRule -DisplayName "File and Printer Sharing (Echo Request - ICMPv4-Out)"
    # Whole Group would be:
    Enable-NetFirewallRule -DisplayGroup "File and Printer Sharing"

    Get-NetFirewallRule `
    | Where-Object { $_.DisplayName -like "*File and Printer Sharing (Echo Request -*" } `
    | Select-Object DisplayName, Enabled, Profile `
    | Format-Table

    Write-Host "=== Successfully set up firewall ===" -ForegroundColor Green
}

function Enable-NginxServer {
    Write-Host "=== Set up nginx ===" -ForegroundColor Yellow

    $nginxPath = "C:\tools\nginx-1.29.3"
    $nginxConf = Join-Path $nginxPath "conf\nginx.conf"

    Write-Host "Stop system service to free up port 80" -ForegroundColor Cyan
    Stop-Service W3SVC

    Write-Host "Install nginx" -ForegroundColor Cyan
    choco install nginx -y

    Copy-Item `
        -Path "\\vboxsrv\shared\nginx.conf" `
        -Destination "$nginxConf" `
        -Force

    $certName = "server.lab"
    $certPath = "$nginxPath\ssl"
    $certPfx = Join-Path $certPath "$certName.pfx"
    $certCrt = Join-Path $certPath "$certName.crt"
    $certKey = Join-Path $certPath "$certName.key"

    New-Item -ItemType Directory -Path $certPath -Force

    Write-Host "Create self-signed certificate in personal store" -ForegroundColor Cyan
    $cert = New-SelfSignedCertificate `
        -DnsName $certName `
        -CertStoreLocation Cert:\LocalMachine\My `
        -KeyExportPolicy Exportable `
        -NotAfter (Get-Date).AddYears(5) `
        -KeyLength 2048 `
        -TextExtension @("2.5.29.19={text}CA=FALSE")

    Write-Host "Export certificate and private key to PFX" -ForegroundColor Cyan
    $securePwd = ConvertTo-SecureString -String "Password123" -Force -AsPlainText
    Export-PfxCertificate -Cert $cert -FilePath $certPfx -Password $securePwd

    Write-Host "Install openssl" -ForegroundColor Cyan
    choco install openssl.light -y
    $opensslpath = "C:\Program Files\OpenSSL\bin\openssl.exe"

    Write-Host "Extract private key" -ForegroundColor Cyan
    & $opensslpath pkcs12 -in $certPfx -nocerts -nodes -out $certKey -passin pass:Password123

    Write-Host "Extract certificate" -ForegroundColor Cyan
    & $opensslpath pkcs12 -in $certPfx -nokeys -out $certCrt -passin pass:Password123

    Write-Host "Restarting Nginx..." -ForegroundColor Cyan
    Stop-Process -Name nginx -Force
    Start-Process "$nginxPath\nginx.exe"  -ArgumentList "-p `"$nginxPath`" -c `"$nginxConf`"" -NoNewWindow

    Write-Host "=== Successfully set up nginx ===" -ForegroundColor Green
}

function Enable-DNS {
    $dnsZone = "lab"

    Write-Host "=== Set up DNS ===" -ForegroundColor Yellow

    Write-Host "Install Windows feature DNS" -ForegroundColor Cyan
    Install-WindowsFeature -Name DNS -IncludeManagementTools

    Write-Host "Reset DNS zone" -ForegroundColor Cyan
    Remove-DnsServerZone -Name $dnsZone -Force

    Write-Host "Add DNS zone" -ForegroundColor Cyan
    Add-DnsServerPrimaryZone -Name $dnsZone -ZoneFile "$dnsZone.dns" -DynamicUpdate "None"

    Write-Host "Verify DNS zone" -ForegroundColor Cyan
    Get-DnsServerZone | Where-Object { $_.ZoneName -eq $dnsZone }

    Write-Host "Add DNS records" -ForegroundColor Cyan
    Add-DnsServerResourceRecordA -Name "server" -ZoneName $dnsZone -IPv4Address "10.0.2.2"

    Write-Host "Verify DNS records" -ForegroundColor Cyan
    Get-DnsServerResourceRecord -ZoneName $dnsZone

    Write-Host "=== Successfully set up DNS ===" -ForegroundColor Green
}

function Enable-VPN {
    Write-Host "Install Windows feature for VPN" -ForegroundColor Cyan
    Install-WindowsFeature DirectAccess-VPN -IncludeManagementTools

    Write-Host "Configuring RRAS for VPN access" -ForegroundColor Cyan
    Install-RemoteAccess -VpnType Vpn
}

function Add-SSTP {
    $PfxPath = "\\vboxsrv\shared\sstp\cert.pfx"
    $CertPass = (ConvertTo-SecureString "Password123" -AsPlainText -Force)

    Write-Host "Import certificate" -ForegroundColor Cyan
    # Cert:\<Scope>\<StoreName>
    $cert = Import-PfxCertificate -FilePath $PfxPath -CertStoreLocation "Cert:\LocalMachine\My" -Password $CertPass

    Write-Host "Confirm import" -ForegroundColor Cyan
    $cert | Format-List Subject, Thumbprint, NotAfter

    Set-RemoteAccess -SslCertificate $cert

    # If this needs to be changed
    # Add-VpnIPAddressRange -IPAddressRange 10.0.1.2, 10.0.1.254
    # Remove-VpnIPAddressRange -IPAddress 123.0.1.2
    Set-VpnIPAddressAssignment -IPAssignmentMethod "StaticPool" -IPAddressRange 10.0.1.2, 10.0.1.254

    Set-VpnAuthProtocol -UserAuthProtocolAccepted MsChapv2

    Get-RemoteAccess

    $Username = "vpnuser"
    $Password = "Password123"
    $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force

    # Create the local user
    New-LocalUser -Name $Username -Password $SecurePassword -FullName "VPN User" -Description "User for SSTP VPN access"

    # Add user to 'Users' group (default)
    Add-LocalGroupMember -Group "Users" -Member $Username

    netsh ras set user name="$Username" dialin=PERMIT
    netsh ras show user
}

function Add-SSTPConnection {
    param (
        [string]$IP
    )

    $certPath = "\\vboxsrv\shared\sstp\cert.cer"

    Remove-VpnConnection -Name "SSTP" -Force
    Add-VpnConnection `
        -Name "SSTP" `
        -ServerAddress "$IP" `
        -TunnelType Sstp `
        -AuthenticationMethod MSChapv2 `
        -RememberCredential `
        -Force

    Import-Certificate -FilePath $certPath -CertStoreLocation Cert:\LocalMachine\Root
}

function Add-OpenVPN {
    param (
        [string]$vmName
    )

    $configPath = "C:\Program Files\OpenVPN\config-auto"

    choco install --force -y openvpn --package-parameters="/WintunDriver /Documentation /SampleConfig /EasyRsa /Service"

    Remove-Item "$configPath\*" -Recurse -Force -ErrorAction SilentlyContinue

    Copy-Item -Path "\\vboxsrv\shared\open_vpn\$vmName\*" -Destination $configPath -Recurse -Force

    Set-Service -Name OpenVPNService -StartupType Automatic

    Start-Service OpenVPNService

    Get-Service OpenVPNService
}

function Invoke-RemoteAccessServiceRestart {
    Write-Host "Restart Remote Access Service" -ForegroundColor Cyan
    Stop-Service RemoteAccess -Force

    Start-Service RemoteAccess

    Set-Service RemoteAccess -StartupType Automatic

    Get-Service RemoteAccess | Format-Table Status, StartType
}

function Invoke-Reboot {
    shutdown /r /f /t 0
}
