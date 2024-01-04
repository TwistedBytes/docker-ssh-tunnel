[![](https://images.microbadger.com/badges/image/cagataygurturk/docker-ssh-tunnel.svg)](https://microbadger.com/images/cagataygurturk/docker-ssh-tunnel)

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
        SSH_DEBUG: ""
        SSH_PORT: 2223
        SSH_USERANDHOST: username@someserver.example.com
        REMOTE_HOST: 127.0.0.1
        LOCAL_PORT: <port in docker>
        REMOTE_PORT: <port on remote_host>

```

1. 2 ways to use it:
   1. ssh-agent, which is the preferred way. as it does not need to copy ssh keys
    
    use this:
```yaml
      volumes:
        - $SSH_AUTH_SOCK:/ssh-agent
      environment:
        SSH_AUTH_SOCK: /ssh-agent
```
   2. ~/.ssh dir copy

    use this:
```yaml
      volumes:
        - $HOME/.ssh:/root/ssh:ro
3.  
