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
apt-get update && apt-get install -y ca-certificates apt-transport-https curl gnupg netcat-openbsd openjdk-17-jre-headless && \
echo 'deb [ arch=amd64,arm64 ] https://www.ui.com/downloads/unifi/debian stable ubiquiti' > /etc/apt/sources.list.d/100-ubnt-unifi.list && \
curl -o /etc/apt/trusted.gpg.d/unifi-repo.gpg -L https://dl.ui.com/unifi/unifi-repo.gpg  && \
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | gpg -o /etc/apt/trusted.gpg.d/mongodb-server-7.0.gpg --dearmor && \
echo "deb [signed-by=/etc/apt/trusted.gpg.d/mongodb-server-7.0.gpg] http://repo.mongodb.org/apt/debian bookworm/mongodb-org/7.0 main" > /etc/apt/sources.list.d/mongodb-org-7.0.list && \
apt-get update && apt-get install -y unifi && \
apt-get remove -y curl 


# add local files
COPY system.properties /defaults/system.properties
COPY run_unifi_network.sh /root/run_unifi_network.sh
COPY block_script.sh  /root/block_script.sh 

# Volumes and Ports
WORKDIR /usr/lib/unifi
VOLUME /config
EXPOSE 8080 8443 8843 8880

#ENTRYPOINT [ "/bin/bash", "/root/run_unifi_network.sh" ]
ENTRYPOINT [ "/bin/bash", "/root/block_script.sh" ]