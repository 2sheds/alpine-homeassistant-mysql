FROM kurapov/alpine-homeassistant:2022.2.9
MAINTAINER Oleg Kurapov <oleg@kurapov.com>

ARG BRANCH="none"
ARG VERSION="none"
ARG COMMIT="local-build"
ARG BUILD_DATE="1970-01-01T00:00:00Z"
ARG NAME="kurapov/alpine-homeassistant-mysql"
ARG VCS_URL="https://github.com/2sheds/alpine-homeassistant-mysql"

ARG UID="1000"
ARG GUID="1000"
ARG PACKAGES="samba-common-tools mariadb-connector-c ffmpeg tiff openjpeg libxslt"
ARG DEPS="shadow zlib-dev libjpeg-turbo-dev tiff-dev freetype-dev lcms2-dev libwebp-dev openjpeg-dev mariadb-dev libxml2-dev libxslt-dev"
ARG PLUGINS="pyotp|PyQRCode|sqlalchemy|wakeonlan|paho-mqtt|netdisco|pysnmp|pushover_complete|hbmqtt|pyfttt|pyemby|steamodd|hole|HAP-python|PyQRCode|fnvhash|base36|aiohomekit|ha-ffmpeg|PyTurboJPEG|pywebpush|holidays|colorlog|pysonos|plexapi|plexauth|plexwebsocket|hkavr|spotipy|samsungctl|samsungtvws|mutagen|pycsspeechtts|pyipp|async-upnp-client|pyowm|emoji|pillow|xbox-webapi|caldav|pyatv"
ARG ALPINE_VER="3.10"
ARG EXTRA_PLUGINS="python-dateutil pycryptodome mysqlclient garminconnect_ha"

ENV WHEELS_LINKS=https://wheels.home-assistant.io/alpine-${ALPINE_VER}/amd64/

LABEL \
  org.opencontainers.image.authors="Oleg Kurapov <oleg@kurapov.com>" \
  org.opencontainers.image.licenses="GPL-2.0-only" \
  org.opencontainers.image.title="${NAME}" \
  org.opencontainers.image.created="${BUILD_DATE}" \
  org.opencontainers.image.revision="${COMMIT}" \
  org.opencontainers.image.source="${VCS_URL}"

RUN apk add --update-cache ${PACKAGES} && \
    apk add --virtual=build-dependencies build-base libffi-dev ${DEPS} && \
    grep -w -E "${PLUGINS}" /usr/src/requirements_all.txt | grep -v '#' > /tmp/requirements_plugins.txt && \
    pip3 install --no-cache-dir --prefer-binary --find-links ${WHEELS_LINKS} ${EXTRA_PLUGINS} -r /tmp/requirements_plugins.txt && \
    usermod -u ${UID} hass && groupmod -g ${GUID} hass && \
    apk del build-dependencies && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/*

EXPOSE 51827

ENTRYPOINT ["hass", "--config=/data"]
