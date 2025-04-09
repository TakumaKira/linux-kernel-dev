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
    qemu-user-static

WORKDIR /kernel