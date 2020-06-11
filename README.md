## Bastion Prime

This is a container modified from the excellent [alpine-sshd](https://github.com/sickp/docker-alpine-sshd) meant to provide an ephemeral bastion container. It's meant for you to copy in `public_keys`
letting people login as user `jump`. It's locked down with basic [hardening](https://gist.github.com/jumanjiman/f9d3db977846c163df12) best practices and meant to be run in with a read-only filesystem.

## Launching (docker)

This is pretty easy to get going:

```
docker run -p 22:2222 inanimate/bastion-prime
```

### Providing options to ssh server

You can override the default `sshd_config` options by passing more to the ssh daemon by passing them as runtime commands:

```
docker run -p 22:2222 inanimate/bastion-prime -o GatewayPorts=yes
```

### Using your own Host Keys and/or inserting public key(s)

You can create a new image based off bastion-prime:

1. Build a docker image sourced from bastion-prime importing your files:

```
FROM inanimate/bastion-prime

# Copy in our own host keys
COPY ssh_host* /etc/ssh/

# Overwrite with our own public key file
COPY public_keys /home/jump/.ssh/authorized_keys
```

2. You could also mount in at runtime:

```
docker run -v /home/me/myauthorizedkeys:/home/jump/.ssh/authorized_ksys -p 22:2222 inanimate/bastion-prime
```

### Security Thoughts and Suggestions upon runtime

Please consider doing these when running this bastion.

* Run with no capabilities `--cap-drop=all`
* Read-only Filesystem (ensure you load in your own host keys or startup generation will fail)
* Apply tight seccomp profile

### Jumping

Using a modern OpenSSH version, you can simply `ssh -J jumphost privatebox.hax.kk`
To spawn a simple dynamic forward, something like `ssh -N -D 55556 -J jumphost` should suffice.

Or, in your `.ssh/config`:
```
Host jumphost
  User jump
  HostName jumphost.public.example.io
  Port 8889
Host privatebox
  User mario
  HostName privatebox.hax.kk
  ProxyJump jumphost
```

Now all you need is `ssh privatebox` and you're off to the races!

## Host Key Handling

By default, host keys are built at launch time if not already existent.
It is *highly* recommended to generate your own host keys and Dockerfile in a repository
to build this image for your needs, so the container can remain ephemeral without regenerated keys
each time it gets recreated! (this could wreck havoc on your clients especially if using something like k8s)

## Hardening Details

While I didn't use the "hardening.sh" script bouncing around gist (see link above), I did implement the relevant bits
that make sense for container of this stature including clearing out binaries like `su`, removing package manager bits, and remove kernel tunable files. *Remember*, this should be run (whether k8s, docker, etc..) in `read-only` mode! I also highly recommend utilizing seccomp or other deployent security enhancements available in your environment.

Some key things I did (view `Dockerfile` and `sshd_config` for all configuration):

* shell to /sbin/nologin
* removal of binaries like `su`
* disable tty
* drop user
* disable sftp
