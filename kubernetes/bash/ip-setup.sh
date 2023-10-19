ip=$(az network public-ip create --resource-group ${1} --name ${2} --allocation-method static --query publicIp.ipAddress)
echo "##vso[task.setvariable variable=${3};]$ip"