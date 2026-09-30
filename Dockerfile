FROM nvcr.io/nvidia/pytorch:25.01-py3

# 1. Stub apt-get and apt so Vast's entrypoint while loop exits immediately
RUN echo '#!/bin/sh\nexit 0' > /usr/local/bin/apt-get && \
    chmod +x /usr/local/bin/apt-get && \
    echo '#!/bin/sh\nexit 0' > /usr/local/bin/apt && \
    chmod +x /usr/local/bin/apt && \
    cp /usr/bin/apt-get /usr/bin/apt-get.orig 2>/dev/null || true && \
    echo '#!/bin/sh\nexit 0' > /usr/bin/apt-get && \
    chmod +x /usr/bin/apt-get && \
    echo '#!/bin/sh\nexit 0' > /usr/bin/apt && \
    chmod +x /usr/bin/apt

# 2. Configure SSH keys and sshd
RUN mkdir -p /root/.ssh /run/sshd && \
    chmod 700 /root/.ssh && \
    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICW7b+Hexufl8hJkv1YRVaZAO++YmAtZEP4U3N2oS8rW rajs-macbook-air" > /root/.ssh/authorized_keys && \
    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILyzNMkENxGkeb9wqTj/hyB19QScDg5q+shm0p8S72hg claude-vast-session-20260906" >> /root/.ssh/authorized_keys && \
    chmod 600 /root/.ssh/authorized_keys && \
    sed -i 's/#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config 2>/dev/null || true && \
    sed -i 's/#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config 2>/dev/null || true && \
    echo "StrictModes no" >> /etc/ssh/sshd_config && \
    ssh-keygen -A

WORKDIR /workspace
