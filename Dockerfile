# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: glibc
# Minimum Panel Version: 0.6.0
# ----------------------------------

FROM        frolvlad/alpine-glibc

ARG         alpine_glibc_version=2.29-r0

LABEL       author="Pterodactyl Software" maintainer="support@pterodactyl.io"

RUN         apk --no-cache add ca-certificates wget curl libstdc++ \
            && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
            && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${alpine_glibc_version}/glibc-${alpine_glibc_version}.apk \
            && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${alpine_glibc_version}/glibc-bin-${alpine_glibc_version}.apk \
            && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${alpine_glibc_version}/glibc-i18n-${alpine_glibc_version}.apk \
            && apk add glibc-${alpine_glibc_version}.apk \
            && apk add glibc-bin-${alpine_glibc_version}.apk \
            && apk add glibc-i18n-${alpine_glibc_version}.apk \
            && adduser -D -h /home/container container \
            && rm \
            /lib/ld-linux-x86-64.so.2 \
            /etc/ld.so.cache \
            && echo "/usr/glibc-compat/lib" > /usr/glibc-compat/etc/ld.so.conf \
            && /usr/glibc-compat/sbin/ldconfig -i \
            && rm -r \
            /var/cache/ldconfig/aux-cache \
            /var/cache/ldconfig

USER        container

ENV         USER=container HOME=/home/container

WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh

CMD         ["/bin/ash", "/entrypoint.sh"]
