FROM ubuntu

# set version label
ARG BUILD_DATE
ARG VERSION
ARG UNIFI_VERSION
LABEL build_version="Version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="cypherfox"

# environment settings
ARG UNIFI_BRANCH="stable"
ENV DEBIAN_FRONTEND="noninteractive"

RUN \
apt-get update && apt-get install ca-certificates apt-transport-https curl -y && \
echo 'deb [ arch=amd64,arm64 ] https://www.ui.com/downloads/unifi/debian stable ubiquiti' > /etc/apt/sources.list.d/100-ubnt-unifi.list && \
curl -o /etc/apt/trusted.gpg.d/unifi-repo.gpg -L https://dl.ui.com/unifi/unifi-repo.gpg  && \
apt-get update && sudo apt-get install unifi -y && \
apt-get remove curl


# add local files
COPY system.properties /defaults/system.properties
COPY run_unifi_network.sh /root/run_unifi_network.sh

# Volumes and Ports
WORKDIR /usr/lib/unifi
VOLUME /config
EXPOSE 8080 8443 8843 8880

ENTRYPOINT [ "/bin/bash", "/root/run_unifi_network.sh" ]