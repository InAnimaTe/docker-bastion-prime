FROM sickp/alpine-sshd:7.5-r2

# Please run this with a read-only filesystem :)

ENV DROPUSER jump

# [Highly Recommended] Copy in static Host keys so this is truly ephemeral
#COPY ssh_host* /etc/ssh/

# Disable root passwd, ensure perms, lockdown
RUN passwd -d root && \
    # ** Uncomment if copying host keys (see above) only!
    #chmod 600 /etc/ssh/ssh_host* && \
    adduser -D -s /sbin/nologin $DROPUSER && \
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

# Copy in our public keys file
COPY public_keys /home/$DROPUSER/.ssh/authorized_keys

# Copy in our own sshd_config with more tunings
COPY sshd_config /etc/ssh/sshd_config

# Set port
EXPOSE 2222

# Set locked user
USER $DROPUSER

# See base image for more information: https://github.com/sickp/docker-alpine-sshd
