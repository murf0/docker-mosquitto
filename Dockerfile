FROM sillelien/base-alpine:latest

EXPOSE 8883
EXPOSE 8884
EXPOSE 8885

VOLUME ["/var/lib/mosquitto", "/etc/mosquitto", "/etc/mosquitto.d"]

RUN addgroup -S mosquitto adduser -S -H -h /var/empty -s /sbin/nologin -D -G mosquitto mosquitto

COPY build.sh /build.sh
RUN chmod 755 /build.sh
RUN /build.sh

COPY mosquitto.sh /etc/services.d/mosquitto/run
RUN chmod 755 /etc/services.d/mosquitto/run

