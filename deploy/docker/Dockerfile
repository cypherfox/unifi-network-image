# syntax=docker/dockerfile:1

FROM alpine:3.20

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
  echo "**** install packages ****" && \
  apk add --no-cache jsvc logrotate openjdk17-jre-headless unzip curl binutils bash && \
  echo "**** install unifi ****" && \
  if [ -z ${UNIFI_VERSION+x} ]; then \
    UNIFI_VERSION=$(curl -sX GET https://dl.ui.com/unifi/debian/dists/${UNIFI_BRANCH}/ubiquiti/binary-amd64/Packages \
    |grep -A 7 -m 1 'Package: unifi' \
    | awk -F ': ' '/Version/{print $2;exit}' \
    | awk -F '-' '{print $1}'); \
  fi && \
  mkdir -p /app && \
  echo "*** download and unpack generic Unix zip ***" && \
  curl -o /tmp/unifi.zip -L "https://dl.ui.com/unifi/${UNIFI_VERSION}/UniFi.unix.zip" && \
  unzip /tmp/unifi.zip -d /usr/lib && \
  mv /usr/lib/UniFi /usr/lib/unifi && \
  echo "*** download and unpack generic Unix zip ***" && \
  curl -o /tmp/unifi.deb -L https://dl.ui.com/unifi/${UNIFI_VERSION}/unifi_sysvinit_all.deb && \
  mkdir /tmp/unifi-package && ar xv --output /tmp/unifi-package /tmp/unifi.deb && \
  mkdir /tmp/data-unpack && tar xvJf /tmp/unifi-package/data.tar.xz -C /tmp/data-unpack && \
  mkdir -p /usr/lib/unifi/lib/native/Linux/x86_64 && \
  cd /tmp/data-unpack/usr/lib/unifi/lib/native/Linux/x86_64 && cp libubnt* /usr/lib/unifi/lib/native/Linux/x86_64 && \
  printf "Linuxserver.io version: ${VERSION}\nBuild-date: ${BUILD_DATE}" > /build_version && \
  echo "**** cleanup ****" && \
  apk del curl binutils && \
  rm -rf \
    /tmp/* \
    /var/tmp/* 

# add local files
COPY system.properties /defaults/system.properties
COPY run_unifi_network.sh /root/run_unifi_network.sh

# Volumes and Ports
WORKDIR /usr/lib/unifi
VOLUME /config
EXPOSE 8080 8443 8843 8880

ENTRYPOINT [ "/bin/bash", "/root/run_unifi_network.sh" ]