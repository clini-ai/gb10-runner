FROM nvcr.io/nvidia/pytorch:25.01-py3

# 1. Install openssh-server, curl, rsync, and useful tools during image build (native Linux kernel on GH Actions)
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    curl \
    wget \
    git \
    rsync \
    sudo \
    psmisc \
    net-tools \
    htop \
    tmux \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# 2. Stub apt-get and apt so Vast's runtime entrypoint while loop exits immediately on Host 150922 (gVisor)
RUN printf '#!/bin/sh\nexit 0\n' > /usr/local/bin/apt-get && \
    chmod +x /usr/local/bin/apt-get && \
    printf '#!/bin/sh\nexit 0\n' > /usr/local/bin/apt && \
    chmod +x /usr/local/bin/apt && \
    cp /usr/bin/apt-get /usr/bin/apt-get.orig 2>/dev/null || true && \
    printf '#!/bin/sh\nexit 0\n' > /usr/bin/apt-get && \
    chmod +x /usr/bin/apt-get && \
    printf '#!/bin/sh\nexit 0\n' > /usr/bin/apt && \
    chmod +x /usr/bin/apt

# 3. Configure SSH keys and sshd
RUN mkdir -p /root/.ssh /run/sshd /var/run/sshd && \
    chmod 700 /root/.ssh && \
    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICW7b+Hexufl8hJkv1YRVaZAO++YmAtZEP4U3N2oS8rW rajs-macbook-air" > /root/.ssh/authorized_keys && \
    echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILyzNMkENxGkeb9wqTj/hyB19QScDg5q+shm0p8S72hg claude-vast-session-20260906" >> /root/.ssh/authorized_keys && \
    chmod 600 /root/.ssh/authorized_keys && \
    sed -i 's/#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    echo "StrictModes no" >> /etc/ssh/sshd_config && \
    ssh-keygen -A

# 4. Pre-configure Jupyter so it runs as root without erroring out
RUN mkdir -p /root/.jupyter && \
    printf "c.NotebookApp.allow_root = True\nc.ServerApp.allow_root = True\nc.NotebookApp.ip = '0.0.0.0'\nc.ServerApp.ip = '0.0.0.0'\nc.NotebookApp.open_browser = False\nc.ServerApp.open_browser = False\n" > /root/.jupyter/jupyter_notebook_config.py && \
    cp /root/.jupyter/jupyter_notebook_config.py /root/.jupyter/jupyter_server_config.py

# 5. Pre-install Python ML dependencies for Wan / Bernini benchmarks
RUN pip install --no-cache-dir \
    diffusers \
    transformers \
    accelerate \
    sentencepiece \
    imageio \
    imageio-ffmpeg \
    opencv-python-headless \
    einops \
    huggingface_hub \
    ftfy

WORKDIR /workspace
