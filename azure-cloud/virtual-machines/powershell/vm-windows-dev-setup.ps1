# allow ICMP ping IPv4
netsh advfirewall firewall add rule name="ICMP Allow incoming V4 echo request" protocol=icmpv4:8,any dir=in action=allow

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
choco install docker-desktop
choco install docker-compose
choco install googlechrome --ignore-checksum
choco install firefox
choco install postman
choco install sourcetree
choco install git.install
choco install git-lfs.install
choco install vscode
choco install azure-cli
az extension add --name mesh
az extension add --name aks-preview
choco install kubernetes-cli
choco install minikube
choco install kubernetes-helm
choco install gcloudsdk
choco install openssl.light
choco install grep
choco install golang
choco install nuget.commandline
choco install gcloudsdk
choco install tartool
choco install sed

# reboot
Restart-Computer
