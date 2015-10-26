#!/usr/bin/with-contenv sh
set -e

chown mosquitto:mosquitto -R /var/lib/mosquitto
exec /usr/local/sbin/mosquitto -c /etc/mosquitto/mosquitto.conf

