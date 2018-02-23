FROM i386/ubuntu:16.04

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="stian larsen,sparklyballs"

# global environment settings
ENV DEBIAN_FRONTEND="noninteractive" \
PLEX_DOWNLOAD="https://downloads.plex.tv/plex-media-server" \
PLEX_INSTALL="https://downloads.plex.tv/plex-media-server/1.11.3.4803-c40bba82e/plexmediaserver_1.11.3.4803-c40bba82e_i386.deb" \
PLEX_MEDIA_SERVER_APPLICATION_SUPPORT_DIR="/config/Library/Application Support" \
PLEX_MEDIA_SERVER_HOME="/usr/lib/plexmediaserver" \
PLEX_MEDIA_SERVER_INFO_DEVICE=docker \
PLEX_MEDIA_SERVER_MAX_PLUGIN_PROCS="6" \
PLEX_MEDIA_SERVER_USER=plex \
LD_LIBRARY_PATH="/usr/lib/plexmediaserver"

RUN \
 echo "**** install packages ****" && \
 apt-get update && \
 apt-get install -y \
	avahi-daemon \
	curl \
	dbus \
	unrar \
	udev \
	wget && \
 echo "**** install plex ****" && \
 curl -o \
	/tmp/plexmediaserver.deb -L \
	"${PLEX_INSTALL}" && \
 dpkg -i /tmp/plexmediaserver.deb && \
 echo "**** change abc home folder to fix plex hanging at runtime with usermod ****" && \
 usermod -d /home/plex plex && \
 echo "**** cleanup ****" && \
 apt-get clean && \
 rm -rf \
	/etc/default/plexmediaserver \
	/tmp/* \
	/var/lib/apt/lists/* \
	/var/tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 32400 32400/udp 32469 32469/udp 5353/udp 1900/udp
VOLUME /config /transcode

CMD ${PLEX_MEDIA_SERVER_HOME}/Plex\ Media\ Server && \
	/bin/bash
