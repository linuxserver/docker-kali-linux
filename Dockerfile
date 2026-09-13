# syntax=docker/dockerfile:1

# build patched libkwin and screencast plugin (x86_64 only, see patches/)
FROM ghcr.io/linuxserver/baseimage-selkies:kali AS kwinbuild
ARG DEBIAN_FRONTEND="noninteractive"

COPY /patches /build/patches

RUN \
  echo "**** install build deps ****" && \
  apt-get update && \
  apt-get install --no-install-recommends -y \
    ca-certificates \
    dpkg-dev && \
  apt-get build-dep -y kwin && \
  echo "**** build patched kwin targets ****" && \
  mkdir -p /build/src && \
  cd /build/src && \
  apt-get source kwin && \
  cd kwin-*/ && \
  for kwin_patch in /build/patches/*.patch; do \
    patch -p1 < "${kwin_patch}"; \
  done && \
  export DEB_BUILD_MAINT_OPTIONS="hardening=+all" && \
  export DEB_BUILD_OPTIONS="nocheck parallel=$(nproc)" && \
  dh_auto_configure -- \
    -DBUILD_TESTING=OFF \
    -DQTWAYLANDSCANNER_KDE_EXECUTABLE=/usr/lib/qt6/libexec/qtwaylandscanner && \
  dh_auto_build -- \
    kwin \
    screencast && \
  echo "**** stage patched files ****" && \
  LIBDIR=/build/patched/usr/lib/x86_64-linux-gnu && \
  mkdir -p \
    ${LIBDIR}/qt6/plugins/kwin/plugins && \
  cp \
    $(find obj-* -name 'libkwin.so.6.*' -type f) \
    ${LIBDIR}/ && \
  cp \
    $(find obj-* -name 'screencast.so' -type f) \
    ${LIBDIR}/qt6/plugins/kwin/plugins/ && \
  strip --strip-unneeded \
    --remove-section=.comment \
    --remove-section=.note \
    ${LIBDIR}/libkwin.so.6.* \
    ${LIBDIR}/qt6/plugins/kwin/plugins/screencast.so

FROM lsiodev/selkies-base:kali

# set version label
ARG BUILD_DATE
ARG VERSION
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="thelamer"

# title
ENV TITLE="Kali Linux" \
    PIXELFLUX_WAYLAND=true

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
    cargo \
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
  cargo install \
    wl-clipboard-rs-tools && \
  echo "**** replace wl-clipboard with rust ****" && \
  mv \
    /config/.cargo/bin/wl-* \
    /usr/bin/ && \
  echo "**** kde tweaks ****" && \
  setcap -r \
    /usr/bin/kwin_wayland && \
  echo "**** cleanup ****" && \
  apt-get autoclean && \
  rm -rf \
    /config/.cache \
    /config/.cargo \
    /var/lib/apt/lists/* \
    /var/tmp/* \
    /tmp/*

# add local files
COPY --from=kwinbuild /build/patched/ /
COPY /root /

# ports and volumes
EXPOSE 3001
VOLUME /config
