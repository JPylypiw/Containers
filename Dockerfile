# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: glibc
# Minimum Panel Version: 0.6.0
# ----------------------------------

FROM        frolvlad/alpine-glibc

ARG         alpine_glibc_version=2.29-r0

ENV         LANG=C.UTF-8

LABEL       author="Pterodactyl Software" maintainer="support@pterodactyl.io"

RUN         apk --no-cache add ca-certificates wget curl libstdc++ \
            && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
            && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${alpine_glibc_version}/glibc-${alpine_glibc_version}.apk \
            && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${alpine_glibc_version}/glibc-bin-${alpine_glibc_version}.apk \
            && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${alpine_glibc_version}/glibc-i18n-${alpine_glibc_version}.apk \
            && apk add --no-cache glibc-${alpine_glibc_version}.apk \
            && apk add --no-cache glibc-bin-${alpine_glibc_version}.apk \
            && apk add --no-cache glibc-i18n-${alpine_glibc_version}.apk \
            && rm -r glibc-${alpine_glibc_version}.apk glibc-bin-${alpine_glibc_version}.apk glibc-i18n-${alpine_glibc_version}.apk \
            \
            # Set the locale
            && /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap UTF-8 "$LANG" || true \
            && echo "export LANG=$LANG" > /etc/profile.d/locale.sh \
            \
            && apk del --no-cache glibc-i18n \
            \
            # Fix ldd
            && sed -i -e 's#/bin/bash#/bin/sh#' /usr/glibc-compat/bin/ldd \
            && sed -i -e 's#RTLDLIST=.*#RTLDLIST="/usr/glibc-compat/lib/ld-linux-x86-64.so.2"#' /usr/glibc-compat/bin/ldd \
            \
            # Isolate the glibc lib's from musl-libc lib's
            && rm /lib/ld-linux-x86-64.so.2 /etc/ld.so.cache \
            && echo "/usr/glibc-compat/lib" > /usr/glibc-compat/etc/ld.so.conf \
            && /usr/glibc-compat/sbin/ldconfig -i \
            && rm -r /var/cache/ldconfig/aux-cache /var/cache/ldconfig \
            \
            # Add User container
            && adduser -D -h /home/container container

USER        container

ENV         USER=container HOME=/home/container

WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh

CMD         ["/bin/ash", "/entrypoint.sh"]
