#!/bin/sh


#git clone https://github.com/fission/fission.git $GOPATH/src/github.com/fission/fission
 cd $GOPATH/src/github.com/fission/fission
# Enable go module and get dependencies
 export GO111MODULE=on
 go mod vendor

# Run checks on your changes
 ./hack/verify-gofmt.sh

 ./hack/verify-govet.sh


# build the container image for Fission 

docker build -t cloudfaas/fission-bundle:1.5.0 -f cmd/fission-bundle/Dockerfile.fission-bundle .
docker login -u cloudfaas
# pull in the dependencies for the helm chart

helm dep update $GOPATH/src/github.com/fission/fission/charts/fission-all

#install fission with the new image 

# helm install --set "image=cloudfaas/fission-bundle,imageTag=1.5.0,pullPolicy=IfNotPresent,analytics=false" charts/fission-all
#version f fission active-standby (old version)
helm install --set "image=cloudfaas/fission-bundle,imageTag=1.5.0,pullPolicy=IfNotPresent,analytics=false,serviceType=NodePort,routerServiceType=NodePort" charts/fission-all
#version of fission vanilla (old version)
helm install --set "image=cloudfaas/fission-bundle,imageTag=1.5.1,pullPolicy=IfNotPresent,analytics=false,serviceType=NodePort,routerServiceType=NodePort" charts/fission-all
#version of fission replication request
helm install --set "image=cloudfaas/fission-bundle,imageTag=1.12.1,pullPolicy=IfNotPresent,analytics=false,serviceType=NodePort,routerServiceType=NodePort" charts/fission-all
#version de vanilla in 1.12.0
helm install --set "image=cloudfaas/fission-bundle,imageTag=1.12.0,pullPolicy=IfNotPresent,analytics=false,serviceType=NodePort,routerServiceType=NodePort" charts/fission-all
#version AS 1.12
helm install --set "image=cloudfaas/fission-bundle,imageTag=1.12.6,pullPolicy=IfNotPresent,analytics=false,serviceType=NodePort,routerServiceType=NodePort" charts/fission-all



## install helm 

cat << EOF >> ~/.helm/repository/repositories.yaml
apiVersion: v1
repositories:
- caFile: ""
  cache: ~/.helm/repository/cache/stable-index.yaml
  certFile: ""
  keyFile: ""
  name: stable
  password: ""
  url: https://kubernetes-charts.storage.googleapis.com
  username: ""
- caFile: ""
  cache: ~/.helm/repository/cache/local-index.yaml
  certFile: ""
  keyFile: ""
  name: local
  password: ""
  url: http://127.0.0.1:8879/charts
  username: ""
EOF


