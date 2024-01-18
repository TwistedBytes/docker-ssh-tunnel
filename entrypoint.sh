#!/usr/bin/env bash

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
  if [[ ${SSH_COMPRESSION} != "no" ]] && [[ ${SSH_COMPRESSION} != "yes" ]]; then
    echo "values for SSH_COMPRESSION: no or yes"
    exit 1;
  fi
  ARG_COMPRESS=${SSH_COMPRESSION}
fi

cat << EOT > ~/.ssh/config
ForwardAgent yes
TCPKeepAlive yes
ConnectTimeout 5
ServerAliveCountMax 10
ServerAliveInterval 15
StrictHostKeyChecking no
UserKnownHostsFile /dev/null
Compression ${ARG_COMPRESS}

EOT

 chmod -R 600 /root/.ssh/*

_SSH_ACTION=""

if [[ -n $LOCAL_PORT ]] && [[ $REMOTE_HOST ]] && [[ $REMOTE_PORT ]]; then
  _SSH_ACTION="-L *:${LOCAL_PORT}:${REMOTE_HOST}:${REMOTE_PORT}"
  _OUTPUT="Connecting to ${SSH_USERANDHOST}, then proxying ${REMOTE_HOST}:${REMOTE_PORT} to *:$LOCAL_PORT ${USING}"
fi
if [[ -n $LOCAL_SOCKS_PORT ]]; then
  _SSH_ACTION="-D *:${LOCAL_SOCKS_PORT}"
  _OUTPUT="Connecting to ${SSH_USERANDHOST}, then socks5 proxying on ${LOCAL_SOCKS_PORT}"
fi

if [[ -z ${_SSH_ACTION} ]]; then
  cat << EOT
Unknown SSH tunnel to create. 2 types: use one or the other
  - SSH port tunnel: LOCAL_PORT REMOTE_HOST REMOTE_PORT
  - SSH socks5 tunnel: LOCAL_SOCKS_PORT
EOT
fi

# output something on start
cat << EOT
twistedbytes/docker-ssh-tunnel:
  ${_OUTPUT}
  Compression: ${ARG_COMPRESS}, (ENV SSH_COMPRESSION=yes/no, compression is desirable on modem lines and other
                  slow connections, but will only slow down things on fast networks)
EOT

if [[ -n ${SSHPASS} ]]; then
  echo using ssh pass to pass password to sshkey
  exec sshpass -P "passphrase for key" -e \
  ssh -q ${SSH_DEBUG} -N \
          ${_SSH_ACTION} \
          -p ${SSH_PORT} ${SSH_USERANDHOST}
else
  exec ssh -q ${SSH_DEBUG} -N \
      ${_SSH_ACTION} \
      -p ${SSH_PORT} ${SSH_USERANDHOST}
fi
