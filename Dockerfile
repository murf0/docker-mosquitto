FROM sillelien/base-alpine:0.10

EXPOSE 8883
EXPOSE 8884
EXPOSE 8885

VOLUME ["/var/lib/mosquitto", "/etc/mosquitto", "/etc/mosquitto.d"]

RUN addgroup -S mosquitto && \
    adduser -S -H -h /var/empty -s /sbin/nologin -D -G mosquitto mosquitto

ENV PATH=/usr/local/bin:/usr/local/sbin:$PATH

RUN buildDeps='git alpine-sdk openssl-dev mariadb-dev libwebsockets-dev c-ares-dev util-linux-dev hiredis-dev curl-dev libxslt docbook-xsl'; \
    mkdir -p /var/lib/mosquitto && \
    touch /var/lib/mosquitto/.keep && \
    mkdir -p /etc/mosquitto.d && \
    apk update && \
    apk add $buildDeps mariadb-libs hiredis libwebsockets libuuid c-ares openssl curl ca-certificates && \
    git clone git://git.eclipse.org/gitroot/mosquitto/org.eclipse.mosquitto.git && \
    cd org.eclipse.mosquitto && \
    git checkout v1.4.4 -b v1.4.4 && \
    sed -i -e "s|(INSTALL) -s|(INSTALL)|g" -e 's|--strip-program=${CROSS_COMPILE}${STRIP}||' */Makefile */*/Makefile && \
    sed -i "s@/usr/share/xml/docbook/stylesheet/docbook-xsl/manpages/docbook.xsl@/usr/share/xml/docbook/xsl-stylesheets-1.78.1/manpages/docbook.xsl@" man/manpage.xsl && \
    # wo WITH_MEMORY_TRACKING=no, mosquitto segfault after receiving first message
    make WITH_MEMORY_TRACKING=no WITH_SRV=yes WITH_WEBSOCKETS=yes && \
    make install && \
    git clone git://github.com/jpmens/mosquitto-auth-plug.git && \
    cd mosquitto-auth-plug && \
    cp config.mk.in config.mk && \
    sed -i "s/MOSQUITTO_SRC =/MOSQUITTO_SRC = ..\//" config.mk && \
    make && \
    cp auth-plug.so /usr/local/lib/ && \
    cp np /usr/local/bin/ && chmod +x /usr/local/bin/np && \
    cd / && rm -rf org.eclipse.mosquitto && \
    cd / && rm -rf mosquitto-auth-plug && \
    apk del $buildDeps && rm -rf /var/cache/apk/*


COPY run.sh /

ENTRYPOINT ["/run.sh"]
CMD ["mosquitto"]

