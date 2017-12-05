FROM debian:stretch

MAINTAINER Adam Cecile <acecile@le-vert.net>

ENV TERM xterm
ENV HOSTNAME cuda-ccminer.local
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /root

# Upgrade base system and install wget to download GPG key
RUN apt update \
    && apt -y -o 'Dpkg::Options::=--force-confdef' -o 'Dpkg::Options::=--force-confold' dist-upgrade \
    && apt-get -y -o 'Dpkg::Options::=--force-confdef' -o 'Dpkg::Options::=--force-confold' --no-install-recommends install wget ca-certificates gnupg \
    && rm -rf /var/lib/apt/lists/*

# Install my custom repository with mining Debian packages
# and then install ccminer (without CUDA dependency, this will be handled by nvidia-docker)
COPY fake-cuda-deps-for-nvidia-docker_1.0_all.deb /tmp/
RUN wget -O - https://packages.le-vert.net/packages.le-vert.net.gpg.key | apt-key add - \
    && echo "deb http://packages.le-vert.net/mining/debian stretch main" > /etc/apt/sources.list.d/packages_le_vert_net_php5_fpm_squeeze.list \
    && echo "deb http://deb.debian.org/debian stretch contrib non-free" >> /etc/apt/sources.list \
    && apt update \
    && dpkg -i /tmp/fake-cuda-deps-for-nvidia-docker_1.0_all.deb && rm -f /tmp/fake-cuda-deps-for-nvidia-docker_1.0_all.deb \
    && apt-get -y -o 'Dpkg::Options::=--force-confdef' -o 'Dpkg::Options::=--force-confold' --no-install-recommends --ignore-missing install ccminer-tpruvot \
    && rm -rf /var/lib/apt/lists/*

# nvidia-container-runtime @ https://gitlab.com/nvidia/cuda/blob/ubuntu16.04/8.0/runtime/Dockerfile
ENV PATH /usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64
LABEL com.nvidia.volumes.needed="nvidia_driver"
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
