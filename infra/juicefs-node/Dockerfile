FROM alpine:3.19

RUN apk add --no-cache curl ca-certificates fuse

RUN curl -sSL --retry 5 --retry-delay 3 --retry-connrefused \
    https://github.com/juicedata/juicefs/releases/download/v1.2.0/juicefs-1.2.0-linux-amd64.tar.gz -o juicefs.tar.gz \
    && tar -zxvf juicefs.tar.gz -C /usr/local/bin juicefs \
    && rm juicefs.tar.gz

WORKDIR /mnt/compartilhado
