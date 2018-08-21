FROM alpine:3.8
LABEL maintainer "Mario Loria - https://github.com/inanimate/docker-bastion-prime"

ENV DROPUSER jump

# Copy in static Host keys so this is truly ephemeral
ONBUILD COPY ssh_host* /etc/ssh/

# Copy in our public keys file
ONBUILD COPY public_keys /home/$DROPUSER/.ssh/authorized_keys

# Disable root passwd, ensure perms, lockdown
ONBUILD RUN apk --update --no-cache add openssh && \
    passwd -d root && \
    adduser -D -s /bin/false $DROPUSER && \
    passwd -d $DROPUSER && \
    chown -R $DROPUSER:$DROPUSER /home/$DROPUSER /etc/ssh/ && \
    # define sysdirs
    sysdirs=" \
      /bin \
      /etc \
      /lib \
      /sbin \
      /usr \
    " && \
    # Remove suids
    find $sysdirs -xdev -type f -a -perm +4000 -delete && \
    # and other dangerous things
    find $sysdirs -xdev \( \
      -name hexdump -o \
      -name chgrp -o \
      -name chmod -o \
      -name chown -o \
      -name ln -o \
      -name od -o \
      -name strings -o \
      -name su \
      \) -delete && \
      # remove apk stuffs
      find $sysdirs -xdev -regex '.*apk.*' -exec rm -fr {} + && \
      # rm kernel tunables
      rm -fr /etc/sysctl* && \
      rm -fr /etc/modprobe.d && \
      rm -fr /etc/modules && \
      rm -fr /etc/mdev.conf && \
      rm -fr /etc/acpi

# Copy in our own sshd_config with more tunings
COPY sshd_config /etc/ssh/sshd_config

# Set port
EXPOSE 2222

# Copy in entrypoint
COPY entrypoint.sh /entrypoint.sh

# Set locked user
ONBUILD USER $DROPUSER

ENTRYPOINT ["/entrypoint.sh"]
