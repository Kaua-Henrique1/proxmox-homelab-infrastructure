FROM alpine:latest
RUN apk add --no-cache curl fuse
RUN curl -sSL https://github.com/juicedata/juicefs/releases/download/v1.2.0/juicefs-1.2.0-linux-amd64.tar.gz | tar -zx -C /usr/local/bin juicefs
