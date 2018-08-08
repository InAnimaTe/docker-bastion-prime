## Bastion Prime

This is a container modified from the excellent [alpine-sshd](https://github.com/sickp/docker-alpine-sshd) meant
to provide an ephemeral bastion container. It's meant for you to copy in `public_keys`
letting people login as user `jump`. It's locked down with basic [hardening](https://gist.github.com/jumanjiman/f9d3db977846c163df12) best practices and meant to be run in with a read-only filesystem.

## Host Key Handling

By default, host keys are built at launch time if not already existent.
It is *highly* recommended to generate your own host keys and Dockerfile in a repository
to build this image for your needs, so the container can remain ephemeral without regenerated keys
each time it gets recreated! (this could wreck havoc on your clients especially if using something like k8s)

## Usage

This is pretty easy to get going:

```
docker run -p 22:2222 inanimate/bastion-prime
```

> Yep, I left my public key in there so if you don't remove it, I has axx to your boxes ;) (j/k)

## Hardening Details

While I didn't use the "hardening.sh" script bouncing around gist (see link above), I did implement the relevant bits
that make sense for container of this stature including clearing out binaries like `su`, removing package manager bits, and remove kernel tunable files. *Remember*, this should be run (whether k8s, docker, etc..) in `read-only` mode! I also highly recommend utilizing seccomp or other deployent security enhancements available in your environment.
