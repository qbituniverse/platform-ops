# open firewall to allow file copy
netsh advfirewall firewall set rule group="File and Printer Sharing" new enable=Yes

# clean up Docker
Uninstall-Package -Name docker -ProviderName DockerMsftProvider
Uninstall-Module -Name DockerMsftProvider
Get-HNSNetwork | Remove-HNSNetwork
Remove-Item -Path "C:\ProgramData\Docker" -Recurse -Force

# install choco
Set-ExecutionPolicy Bypass -Scope Process -Force
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco feature enable -n allowGlobalConfirmation

# install dependencies
choco install docker-for-windows
choco install docker-compose
choco install azure-cli

# reboot
Restart-Computer
