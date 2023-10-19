[CmdletBinding()]
Param
(
	[Parameter(Position=0,Mandatory=$false,HelpMessage="Operation: --proxy | --docker-c")]
	[string]$Operation
)

If ($Operation -in "--help") {
	Write-Host -ForegroundColor Green ""
	Write-Host -ForegroundColor Green "Local Environment:"
	Write-Host -ForegroundColor Green ""
	Write-Host -ForegroundColor Green "	[operation]"
	Write-Host -ForegroundColor Green ""
	Write-Host -ForegroundColor Green "	--proxy			Set proxy bypass"
  	Write-Host -ForegroundColor Green "	--docker-c		Allow C drive share"
	Write-Host -ForegroundColor Green ""
	Write-Host -ForegroundColor Green ""
	Write-Host -ForegroundColor Green "Usage:"
	Write-Host -ForegroundColor Green "				local-env.ps1 [operation]"
	Write-Host -ForegroundColor Green ""
	Exit
}

If ($Operation -eq "--proxy") {
	Write-Host -ForegroundColor Green "=========================================================="
	Write-Host -ForegroundColor Green "Setting Proxy Bypass"
	Write-Host -ForegroundColor Green "=========================================================="
	
    	$Wcl = new-object System.Net.WebClient
    	$Wcl.Headers.Add("user-agent", "PowerShell Script")
    	$Wcl.Proxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials

	Write-Host ""
} ElseIf ($Operation -eq "--docker-c") {
	Write-Host -ForegroundColor Red "=========================================================="
	Write-Host -ForegroundColor Red "Set Docker C Drive"
	Write-Host -ForegroundColor Red "=========================================================="
	
	Set-NetConnectionProfile -interfacealias "vEthernet (DockerNAT)" -NetworkCategory Private

	Write-Host ""
} Else {
	Write-Host -ForegroundColor Red "=========================================================="
	Write-Host -ForegroundColor Red "Wrong Operation Received"
	Write-Host -ForegroundColor Red "Use: --proxy | --docker-c"
	Write-Host -ForegroundColor Red "=========================================================="
}
