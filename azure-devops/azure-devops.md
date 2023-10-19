# Azure Devops

## Agents

|Name|Description|
|-----|-----|
|[arm64 Dockerfile](agents/Dockerfile-ado-agent-arm64)<br>[start.sh](agents/start.sh)|Docker hosted ADO agent to work on arm64 architectures.|
|[amd64 Dockerfile](agents/Dockerfile-ado-agent-amd64)<br>[start.sh](agents/start.sh)|Docker hosted ADO agent to work on amd64 architectures.|

**NOTE:** *start.sh* file for arm64 image builds needs to be in LF ending (not CRLF) when running the *docker build*.

### Installation Process
#### Build ADO agent image
```bash
docker build -t my-ado-agent:latest -f <Dockerfile Name> .
```

#### Run ADO agent on the target host
```bash
docker run \
-e AZP_URL="https://<ADO-ORGANISATION>.visualstudio.com" \
-e AZP_TOKEN="<ADO-TOKEN>" \
-e AZP_POOL="<ADO-POOL-NAME>" \
-e AZP_AGENT_NAME="<ADO-AGENT-NAME>" \
-v /var/run/docker.sock:/var/run/docker.sock \
-d --restart=always \
--name my-ado-agent my-ado-agent:latest
```

##### Variables

|Name|Description|
|-----|-----|
|ADO-ORGANISATION|Your Azure DevOps organisation name|
|ADO-TOKEN|PAT Token to allow access to the organisation and perform pipeline actions|
|ADO-POOL-NAME|Pool name for the agent to register. Ensure to create it first in ADO Organisation Settings before registering the agent.|
|ADO-AGENT-NAME|Agent name that'll be created and registered in the pool|

## Builds

|Name|Description|
|-----|-----|
|[assign-build-number.yaml](builds/assign-build-number.yaml)|Assign custom build number.|
|[dockerhub-login.yaml](builds/dockerhub-login.yaml)|Login to DockerHub.|
|[create-buildx.yaml](builds/create-buildx.yaml)|Create buildx container for multi-arch image builds.|
|[delete-buildx.yaml](builds/delete-buildx.yaml)|Delete buildx container for multi-arch image builds.|
|[build-push-docker-image-single-arch.yaml](builds/build-push-docker-image-single-arch.yaml)|Build, tag and push Docker image for a single target architecture based on Docker build engine architecture.|
|[build-push-docker-image-multi-arch.yaml](builds/build-push-docker-image-multi-arch.yaml)|Build, tag and push Docker image for multi target architectures using Docker buildx.|

## Releases

|Name|Description|
|-----|-----|
|[assign-release-name.yaml](releases/assign-release-name.yaml)|Assign custom release number.|
