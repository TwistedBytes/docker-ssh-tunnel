FROM alpine:3.15
# MAINTAINER Cagatay Gurturk <cguertuerk@ebay.de>
MAINTAINER Derk Gortemaker <info@twistedbytes.nl>

ENV SSH_PORT=22
ENV SSH_USERANDHOST=user@server

RUN apk add --update openssh-client && rm -rf /var/cache/apk/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 1-65535
