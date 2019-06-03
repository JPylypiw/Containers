# ----------------------------------
# Pterodactyl Core Dockerfile
# Environment: glibc
# Minimum Panel Version: 0.6.0
# ----------------------------------

FROM        frolvlad/alpine-glibc

LABEL       author="Pterodactyl Software" maintainer="support@pterodactyl.io"

RUN         apk --no-cache add ca-certificates wget \
            && wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub \
            && wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.29-r0/glibc-2.29-r0.apk \
            && apk add glibc-2.29-r0.apk \
            && adduser -D -h /home/container container

USER        container

ENV         USER=container HOME=/home/container

WORKDIR     /home/container

COPY        ./entrypoint.sh /entrypoint.sh

CMD         ["/bin/ash", "/entrypoint.sh"]
