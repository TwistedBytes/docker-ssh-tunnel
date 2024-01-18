
# Docker SSH Tunnel

This Docker creates a simple SSH tunnel to a remote server.

## Usage

### Docker compose usage:

Add this to the docker compose:

```yaml
    ssh-tunnel:
      image: twistedbytes/docker-ssh-tunnel
      volumes:
        - $SSH_AUTH_SOCK:/ssh-agent
        # - $HOME/.ssh:/root/ssh:ro
      environment:
        SSH_AUTH_SOCK: /ssh-agent
        #SSHPASS: '${SSH_PASSWORD}' # set SSH_PASSWORD in the docker env file
        #SSH_COMPRESSION: on
        SSH_DEBUG: ""
        SSH_PORT: 2223
        SSH_USERANDHOST: username@someserver.example.com
        # LOCAL_SOCKS_PORT: ${SSH_LOCAL_SOCKS_PORT:-8123}
        REMOTE_HOST: 127.0.0.1
        LOCAL_PORT: ${SSH_LOCAL_PORT:-5432}
        REMOTE_PORT: ${SSH_REMOTE_PORT:-5432}
      # tty: true # only when SSHPASS empty/undefined and no socks
      expose:
        - ${SSH_LOCAL_PORT:-5432}
        - ${LOCAL_SOCKS_PORT:-8123}

```

1. 2 ways to use it:
1. ssh-agent, which is the preferred way. as it does not need to copy ssh keys and no sshkey password issues.
    
    Use this:
     ```yaml
       volumes:
         - $SSH_AUTH_SOCK:/ssh-agent
       environment:
         SSH_AUTH_SOCK: /ssh-agent
     ```
2. ~/.ssh dir copy
       
   If you have a password on your sshkey, this will not work.

   Use this:
    ```yaml
      volumes:
        - $HOME/.ssh:/root/ssh:ro
      environment:
        SSHPASS: "XXXXX" # or leave empty or do not set when no pass on key or type manual
    ```

2. 2 service types:
   1. ssh port tunnel
     ```yaml
       environment:
         REMOTE_HOST: '${SSH_REMOTE_HOST:-10.0.0.1}'
         LOCAL_PORT: '${SSH_LOCAL_PORT:-5432}'
         REMOTE_PORT: '${SSH_REMOTE_PORT:-5432}'
     ```
2. ssh socks5 proxy
     ```yaml
       environment:
         LOCAL_SOCKS_PORT: '${SSH_LOCAL_SOCKS_PORT:-8123}'
     ```

3. Then in other services reference to host ssh-tunnel and port in LOCAL_PORT to use the tunneled service
4. You probably want to rename the service to something explaining what it is: postgres-tunnel-staging

4. Laravel config:
   1. Example:
      ```php
      ...
      'database' => env('DB_DATABASE', 'postgres-tunnel-staging'),
      'port' => env('DB_PORT', 5432),
      ...
      ```