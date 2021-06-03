FROM kurapov/alpine-homeassistant
MAINTAINER Oleg Kurapov <oleg@kurapov.com>

ARG BRANCH="none"
ARG VERSION="none"
ARG COMMIT="local-build"
ARG BUILD_DATE="1970-01-01T00:00:00Z"
ARG NAME="kurapov/alpine-homeassistant-mysql"
ARG VCS_URL="https://github.com/2sheds/alpine-homeassistant-mysql"

ARG UID="1000"
ARG GUID="1000"
ARG PACKAGES="samba-common-tools mariadb-connector-c ffmpeg tiff"
ARG DEPS
ARG PLUGINS="pyotp|PyQRCode|sqlalchemy|wakeonlan|paho-mqtt|netdisco|pysnmp|apcaccess|pushover_complete|hbmqtt|pyfttt|pyemby|steamodd|hole|HAP-python|PyQRCode|fnvhash|base36|aiohomekit|ha-ffmpeg|PyTurboJPEG|pywebpush|holidays|colorlog|pysonos|plexapi|plexauth|plexwebsocket|hkavr|garminconnect_aio|spotipy|samsungctl|samsungtvws|mutagen|pycsspeechtts|pyipp|async-upnp-client|pyowm|emoji|pillow"
ARG ALPINE_VER="3.10"
ARG EXTRA_PLUGINS="mysqlclient python-dateutil pycryptodome"

ENV WHEELS_LINKS=https://wheels.home-assistant.io/alpine-${ALPINE_VER}/amd64/

LABEL \
  org.opencontainers.image.authors="Oleg Kurapov <oleg@kurapov.com>" \
  org.opencontainers.image.licenses="GPL-2.0-only" \
  org.opencontainers.image.title="${NAME}" \
  org.opencontainers.image.created="${BUILD_DATE}" \
  org.opencontainers.image.revision="${COMMIT}" \
  org.opencontainers.image.source="${VCS_URL}"

RUN apk add --update-cache ${PACKAGES} && \
    grep -w -E "${PLUGINS}" /usr/src/requirements_all.txt | grep -v '#' > /tmp/requirements_plugins.txt && \
    pip3 install --no-cache-dir --no-index --only-binary=:all: --find-links ${WHEELS_LINKS} ${EXTRA_PLUGINS} -r /tmp/requirements_plugins.txt && \
    apk add --virtual=build-dependencies shadow ${DEPS} && \
    usermod -u ${UID} hass && groupmod -g ${GUID} hass && \
    apk del build-dependencies && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/*

EXPOSE 51827

ENTRYPOINT ["hass", "--config=/data"]
