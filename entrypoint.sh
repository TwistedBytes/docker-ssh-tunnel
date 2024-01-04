#!/usr/bin/env sh

set -e
# set -x

rm -rf /root/.ssh
mkdir /root/.ssh

if [[ -z $SSH_AUTH_SOCK  ]]; then
    USING="using volume /ssh"
    if [[ ! -d /root/ssh/ ]]; then
      echo "no root/ssh volume, please set in docker-compose:
              volumes:
                - \$HOME/.ssh:/root/ssh:ro
            "
      echo "Or use ssh agent:
              volumes:
                - \$SSH_AUTH_SOCK:/ssh-agent
              environment:
                SSH_AUTH_SOCK: /ssh-agent
      "
      exit 1

    else
      cp -R /root/ssh/* /root/.ssh/
    fi
else
    USING="using ssh agent"
fi

ARG_COMPRESS=no
if [[ -n "${SSH_COMPRESSION}" ]]; then
  ARG_COMPRESS=${SSH_COMPRESSION}
fi

#cat << EOT > ~/.ssh/config
#ForwardAgent yes
#TCPKeepAlive yes
#ConnectTimeout 5
#ServerAliveCountMax 10
#ServerAliveInterval 15
#StrictHostKeyChecking no
#UserKnownHostsFile /dev/null
#Compression ${ARG_COMPRESS}
#
#EOT
#
#chmod -R 600 /root/.ssh/*

# output something on start
cat << EOT
twistedbytes/docker-ssh-tunnel:
  Connecting to ${SSH_USERANDHOST}, then proxying ${REMOTE_HOST}:${REMOTE_PORT} to *:$LOCAL_PORT ${USING}
  Compression: ${ARG_COMPRESS}, (ENV SSH_COMPRESSION=yes/no, compression is desirable on modem lines and other
                  slow connections, but will only slow down things on fast networks)
EOT

if [[ -n ${SSHPASS} ]]; then
  echo using ssh pass to pass password to sshkey
  sshpass -P "passphrase for key" -e \
  ssh -q ${SSH_DEBUG} -N \
          -L *:${LOCAL_PORT}:${REMOTE_HOST}:${REMOTE_PORT} \
          -p ${SSH_PORT} ${SSH_USERANDHOST}
else
  exec ssh -q ${SSH_DEBUG} -N \
      -L *:${LOCAL_PORT}:${REMOTE_HOST}:${REMOTE_PORT} \
      -p ${SSH_PORT} ${SSH_USERANDHOST}
fi
