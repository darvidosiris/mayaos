FROM mcr.microsoft.com/devcontainers/base:debian-12

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    qemu-system-x86 novnc websockify gh unzip ca-certificates \
    && rm -rf /var/lib/apt/lists/*
