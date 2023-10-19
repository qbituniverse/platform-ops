#############################################################################
# Setup Variables
#############################################################################
# AWS Account Name
$accountName = "<AWS ACCOUNT NAME>"

# Remaining Variables
$eksName = "eks-dns-lb-c1"
$region = "eu-west-2"
$kubernetesVersion = "1.19"
$nodeType = "t3.medium"
$nodeCount = "1"
$volumeSize = "32"
$maxPods = "110"
$sslDomainName = "eks-dns-lb.platformops.dev"

#############################################################################
# Provision AWS SSL Certificate
#############################################################################
# Deploy AWS SSL Certificate
aws acm request-certificate `
--domain-name $sslDomainName `
--validation-method DNS `
--idempotency-token 91adc45q `
--options CertificateTransparencyLoggingPreference=ENABLED

# Acquire SSL Cert Name & Value
$acmArn = (aws acm list-certificates `
--query 'CertificateSummaryList[*].CertificateArn' --output text)

Write-Host "DNS Name =>" `
(aws acm describe-certificate --certificate-arn $acmArn `
--query 'Certificate.DomainValidationOptions[0].ResourceRecord.Name' `
--output text)

Write-Host "DNS Value =>" `
(aws acm describe-certificate --certificate-arn $acmArn `
--query 'Certificate.DomainValidationOptions[0].ResourceRecord.Value' `
--output text)

# Configure DNS
# CNAME Record => DNS Name => DNS Value

#############################################################################
# Provision EKS Cluster
#############################################################################
# Deploy EKS
eksctl create cluster `
--name $eksName `
--region $region `
--version $kubernetesVersion `
--node-type $nodeType `
--nodes $nodeCount `
--node-volume-size $volumeSize `
--max-pods-per-node $maxPods

#############################################################################
# Deploy Applications in EKS
#############################################################################
# Show Context Details
kubectl config get-contexts
kubectl config current-context

# Get AWS SSL Cert ARN Value and replace in deploy.yaml
Write-Host "AWS SSL CERT ARN =>" $acmArn

# Manually replace in deploy.yaml as per example below
# service.beta.kubernetes.io/aws-load-balancer-ssl-cert: <AWS SSL CERT ARN>

# Deploy Sample EKS Application
kubectl apply -f yaml/deploy.yaml

# Check Deployments
kubectl get all -n eks-dns-lb

#############################################################################
# Configure DNS
#############################################################################
# Acquire Public DNS Name
Write-Host "Public DNS Value =>" `
(aws elb describe-load-balancers --query 'LoadBalancerDescriptions[*].DNSName' `
--output text)

# Configure DNS
# CNAME Record => eks-dns-lb => Public DNS Value

#############################################################################
# Clean-up
#############################################################################
# Delete EKS Deployments
kubectl delete namespace eks-dns-lb

# Delete AWS Resources
eksctl delete cluster --name $eksName
aws acm delete-certificate --certificate-arn $acmArn