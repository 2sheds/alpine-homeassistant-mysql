FROM kurapov/alpine-homeassistant:2025.5.2
MAINTAINER Oleg Kurapov <oleg@kurapov.com>

ENV WHEELS_INDEX="https://wheels.home-assistant.io/musllinux-index/"

ARG UID="1000"
ARG GUID="1000"

ARG PACKAGES="samba-common-tools mariadb-connector-c ffmpeg tiff openjpeg libxslt v4l-utils ir_keytable libturbojpeg libpcap-dev"
ARG DEPS="shadow zlib-dev libjpeg-turbo-dev tiff-dev freetype-dev lcms2-dev libwebp-dev openjpeg-dev mariadb-dev libxml2-dev libxslt-dev"
ARG PLUGINS="pyotp|PyQRCode|sqlalchemy|lru-dict|wakeonlan|paho-mqtt|netdisco|pysnmp|pushover_complete|hbmqtt|pyfttt|pyemby|steamodd|hole|HAP-python|PyQRCode|fnvhash|base36|aiohomekit|ha-ffmpeg|PyTurboJPEG|pywebpush|holidays|colorlog|pysonos|soco|plexapi|plexauth|plexwebsocket|hkavr|spotipy|samsungctl|samsungtvws|getmac|mutagen|pycsspeechtts|pyipp|async-upnp-client|pyowm|emoji|pillow|xbox-webapi|caldav|icalendar|connect-box|bleak|dbus-fast|bluetooth-data-tools|bluetooth-adapters|bluetooth-auto-recovery|xiaomi-ble|pyudev|pyserial|aiousbwatcher|habluetooth|aioesphomeapi|janus|hassil|home-assistant-intents|aioesphomeapii|esphome-dashboard-api|aioshelly|fnv-hash-fast|webrtcvad|aioruuvigateway|sonos-websocket|python-otbr-api|pyroute2|asyncinotify|aiohttp-cors|Pillow|SQLAlchemy|PlexAPI|pushover-complete|numpy|webrtc-noise-gain|python-matter-server|ha-av|WSDiscovery|onvif-zeep-async|pyatv|PyMetno|babel|jsonpath|xmltodict|ical|aiodhcpwatcher|pysnmp-lextudio|isal|pymicro-vad|cached-ipaddress|pyspeex-noise|av|spotifyaio|aioharmony|music-assistant-client"

COPY requirements.txt /tmp/requirements_extra.txt
RUN apk add --update-cache ${PACKAGES} && \
    apk add --virtual=build-dependencies build-base libffi-dev ${DEPS} && \
    grep -w -E "${PLUGINS}" /usr/src/requirements_all.txt | grep -v '#' > /tmp/requirements_plugins.txt && \
    pip3 install --no-cache-dir --prefer-binary --extra-index-url ${WHEELS_INDEX} -r /tmp/requirements_extra.txt -r /tmp/requirements_plugins.txt && \
    usermod -u ${UID} hass && groupmod -g ${GUID} hass && \
    apk del build-dependencies && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/*

ARG BRANCH="none"
ARG VERSION="none"
ARG COMMIT="local-build"
ARG BUILD_DATE="1970-01-01T00:00:00Z"
ARG NAME="kurapov/alpine-homeassistant-mysql"
ARG VCS_URL="https://github.com/2sheds/alpine-homeassistant-mysql"

LABEL \
  org.opencontainers.image.authors="Oleg Kurapov <oleg@kurapov.com>" \
  org.opencontainers.image.licenses="GPL-2.0-only" \
  org.opencontainers.image.title="${NAME}" \
  org.opencontainers.image.created="${BUILD_DATE}" \
  org.opencontainers.image.revision="${COMMIT}" \
  org.opencontainers.image.source="${VCS_URL}"

ENTRYPOINT ["hass", "--config=/data"]
EXPOSE 51827
