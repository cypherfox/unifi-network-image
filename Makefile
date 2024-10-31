.PHONY: image helm-build

image:
	cd deploy/docker ; docker build .

helm-build:
	cd deploy/helm ; helm package ./unifi-network

helm-deploy:
	helm upgrade community-operator mongodb/community-operator --install --namespace mongodb --create-namespace --set community-operator-crds.enabled=true --set operator.watchNamespace="*"
	cd deploy/helm ; helm upgrade unifi-network ./unifi-network-0.1.0.tgz --install --namespace unifi-network --create-namespace

kind-start:
	kind create cluster

kind-load-images:
	docker pull ghcr.io/cypherfox/unifi-network-image/unifi-network:latest
	kind load docker-image ghcr.io/cypherfox/unifi-network-image/unifi-network:latest
# Install the rest:
# 
# helm repo add mongodb https://mongodb.github.io/helm-charts
#
