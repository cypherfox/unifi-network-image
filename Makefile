.PHONY: image helm-build

image:
	cd deploy/docker ; docker build .

helm-build:
	cd deploy/helm ; helm package ./unifi-network

helm-deploy:
	helm install community-operator mongodb/community-operator --namespace mongodb --set community-operator-crds.enabled=false
	cd deploy/helm ; ls -la ; helm install unifi-network ./unifi-network-0.1.0.tgz


# Install the rest:
# 
# helm repo add mongodb https://mongodb.github.io/helm-charts
#
# run only once:
# helm install community-operator mongodb/community-operator --namespace mongodb --create-namespace