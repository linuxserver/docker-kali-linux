# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-selkies:kali

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# title
ENV TITLE="Kali Linux" \
    NO_GAMEPAD=true

RUN \
  echo "**** add icon ****" && \
  curl -o \
    /usr/share/selkies/www/icon.png \
    https://raw.githubusercontent.com/linuxserver/docker-templates/master/linuxserver.io/img/kali-logo.png && \
  echo "**** install packages ****" && \
  apt-get update && \
  DEBIAN_FRONTEND=noninteractive \
  apt-get install -y --no-install-recommends \
    autopsy \
    cutycapt \
    dirbuster \
    dolphin \
    faraday \
    fern-wifi-cracker \
    guymager \
    gwenview \
    hydra \
    kali-desktop-kde \
    kali-linux-default \
    kali-tools-top10 \
    kate \
    kde-config-gtk-style \
    kdialog \
    kfind \
    kio-extras \
    knewstuff-dialog \
    konsole \
    ksystemstats \
    kwin-addons \
    kwin-x11 \
    legion \
    ophcrack \
    ophcrack-cli \
    plasma-desktop \
    plasma-workspace \
    qml-module-qt-labs-platform \
    qt6-svg-plugins \
    sqlitebrowser \
    systemsettings && \
  echo "**** kde tweaks ****" && \
  sed -i \
    's/applications:org.kde.discover.desktop,/applications:org.kde.konsole.desktop,/g' \
    /usr/share/plasma/plasmoids/org.kde.plasma.taskmanager/contents/config/main.xml && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# add local files
COPY /root /

# ports and volumes
EXPOSE 3001
VOLUME /config
