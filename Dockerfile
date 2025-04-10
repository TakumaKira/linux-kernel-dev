FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Install build tools and dependencies for kernel development
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    libncurses-dev \
    bison \
    flex \
    libssl-dev \
    bc \
    cpio \
    qemu \
    qemu-system-arm \
    qemu-system-x86 \
    qemu-user-static \
    ccache

# Configure ccache (adjust size as needed)
RUN ccache -M 50G

# Create symbolic links for cross-compiler (adjust paths if needed)
RUN ln -s /usr/bin/ccache /usr/local/bin/aarch64-linux-gnu-gcc && \
    ln -s /usr/bin/ccache /usr/local/bin/aarch64-linux-gnu-ar && \
    ln -s /usr/bin/ccache /usr/local/bin/aarch64-linux-gnu-ld

WORKDIR /kernel
