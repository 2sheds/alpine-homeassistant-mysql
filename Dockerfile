FROM kurapov/alpine-homeassistant
MAINTAINER Oleg Kurapov <oleg@kurapov.com>

ARG UID="1000"
ARG GUID="1000"
ARG PACKAGES="samba-common-tools mariadb-connector-c"
ARG DEPS="shadow"
ARG PLUGINS="ass-nabucasa|HAP-python|pysnmp|async-upnp-client|apcaccess|netdisco|python-pushover|hbmqtt|mutagen|libsoundtouch|pyfttt|pyemby|steamodd|hole|homekit|PyNaCl|gTTS-token|pywebpush|py_vapid|holidays"
ARG ALPINE_VER="3.10"
ARG EXTRA_PLUGINS="mysqlclient"

ENV WHEELS_LINKS=https://wheels.home-assistant.io/alpine-${ALPINE_VER}/amd64/

RUN apk add --no-cache ${PACKAGES} && \
    apk add --no-cache --virtual=build-dependencies build-base linux-headers python3-dev shadow ${DEPS} && \
    egrep -e "${PLUGINS}" /requirements_plugins.txt | grep -v '#' > /tmp/requirements_plugins_filtered.txt && \
    pip3 install --no-cache-dir --no-index --only-binary=:all: --find-links ${WHEELS_LINKS} -r /tmp/requirements_plugins_filtered.txt && \
    pip3 install --no-cache-dir --no-index --only-binary=:all: --find-links ${WHEELS_LINKS} ${EXTRA_PLUGINS} && \
    usermod -u ${UID} hass && groupmod -g ${GUID} hass && \
    apk del build-dependencies && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/*

EXPOSE 51827

ENTRYPOINT ["hass", "--config=/data"]
