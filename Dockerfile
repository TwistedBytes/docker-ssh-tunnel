FROM alpine:3.15
# MAINTAINER Cagatay Gurturk <cguertuerk@ebay.de>
MAINTAINER Derk Gortemaker <info@twistedbytes.nl>

ENV SSH_PORT=22
ENV SSH_USERANDHOST=user@server

RUN apk add --update openssh-client && rm -rf /var/cache/apk/*

#CMD set -x ; if [[ -z $SSH_AUTH_SOCK  ]]; then rm -rf /root/.ssh && mkdir /root/.ssh && cp -R /root/ssh/* /root/.ssh/ && chmod -R 600 /root/.ssh/*; fi && \
#ssh \
#$SSH_DEBUG \
#-o StrictHostKeyChecking=no \
#-L *:$LOCAL_PORT:$REMOTE_HOST:$REMOTE_PORT \
#-N \
#-p ${SSH_PORT} ${SSH_USERANDHOST} \
#&& while true; do sleep 30; done;

COPY entrypoint.sh /entrypoint.sh
RUN chmod 755 /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 1-65535
