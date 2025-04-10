# Linux Kernel Development

## Setup

### Prepare the environment

(For Mac) Create a case-sensitive volume

```sh (host machine)
hdiutil create -size 20g -fs "Case-sensitive APFS" -volname CaseSensitiveVolume CaseSensitiveVolume.dmg
hdiutil attach CaseSensitiveVolume.dmg
```

Clone this repository in the case-sensitive volume

```sh (host machine)
cd /Volumes/CaseSensitiveVolume/
git clone https://github.com/TakumaKira/linux-kernel-dev.git
cd linux-kernel-dev
```

Clone the linux kernel repository

```sh (host machine)
git clone https://github.com/torvalds/linux.git
```

Create a docker image for linux kernel development

```sh (host machine)
docker build -t linux-kernel-dev .
```

Run the container with mounting the linux directory to the kernel directory of the container

```sh (host machine)
cd linux
docker run -it --rm -v "$(pwd):/kernel" linux-kernel-dev bash
```

### Build the kernel

Generate a defconfig file

```shell (linux-kernel-dev container)
make ARCH=arm64 defconfig
```

Build the kernel (Takes a long time)

```shell (linux-kernel-dev container)
ccache make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc)
```

### Install QEMU

```sh (host machine)
brew install qemu
``` 

### Prepare rootfs image

```sh (host machine)
docker run --platform linux/arm64 --privileged -it --name arm64-builder ubuntu:22.04 bash
```

```shell (arm64-builder container)
# Install necessary packages
apt update && apt install -y \
    debootstrap qemu-user-static \
    fdisk e2fsprogs squashfs-tools \
    wget file

# Download the rootfs image
debootstrap --arch=arm64 jammy /tmp/ubuntu-rootfs http://ports.ubuntu.com/ubuntu-ports

# Create the empty rootfs image
dd if=/dev/zero of=rootfs.img bs=1M count=2048

# Create the ext4 filesystem
mkfs.ext4 rootfs.img

# Create the mount point
mkdir /mnt/rootfs

# Mount the rootfs image
mount -o loop rootfs.img /mnt/rootfs

# Copy the rootfs image to the rootfs
cp -a /tmp/ubuntu-rootfs/* /mnt/rootfs/

# Unmount the rootfs image
umount /mnt/rootfs
```

### Verify the rootfs image

```shell (arm64-builder container)
# Re-mount the image
mount -o loop rootfs.img /mnt/rootfs

# Check /bin/sh
file /mnt/rootfs/bin/sh
# Expected output: "symbolic link to dash"

umount /mnt/rootfs
```

### Copy the rootfs image to the linux directory

```sh (host machine)
docker cp arm64-builder:/rootfs.img ./rootfs.img
```

Move the rootfs.img to the linux directory.

You can now use this rootfs.img with QEMU.

## Run

### Run QEMU

In /linux directory, run QEMU with your compiled kernel:

```sh
cd linux
qemu-system-aarch64 \
  -machine virt \
  -cpu cortex-a72 \
  -kernel arch/arm64/boot/Image \
  -append "console=ttyAMA0 root=/dev/vda rw init=/bin/sh" \
  -drive file=rootfs.img,format=raw,if=virtio \
  -nographic
```

Now you can interact with the kernel built from the linux directory.

If you want to exit QEMU, press `Ctrl+a` then `x`.

### Modify the kernel

Try change the behavior of the kernel by editing the source code.

```c
// /linux/init/main.c
...
void start_kernel(void)
{
	printk(KERN_INFO "Hello from the modified kernel!\n");
  ...
}
...
```

### Build the modified kernel

```bash (linux-kernel-dev container)
# Build the modified file of the kernel
make init/main.c

# Build the modified kernel (Takes a long time)
ccache make ARCH=arm64 CROSS_COMPILE=aarch64-linux-gnu- -j$(nproc)
```

### Verify the modified kernel

Re-run QEMU with the modified kernel:

```sh
qemu-system-aarch64 \
  -machine virt \
  -cpu cortex-a72 \
  -kernel arch/arm64/boot/Image \
  -append "console=ttyAMA0 root=/dev/vda rw init=/bin/sh" \
  -drive file=rootfs.img,format=raw,if=virtio \
  -nographic
```

And search the modified kernel message in the QEMU output.

```bash (QEMU)
dmesg | grep "Hello from the modified kernel"
# [    0.000000] Hello from the modified kernel!
```

If you want to exit QEMU, press `Ctrl+a` then `x`.
