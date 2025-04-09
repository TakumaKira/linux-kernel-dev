(For Mac) Create a case-sensitive volume

```sh
hdiutil create -size 20g -fs "Case-sensitive APFS" -volname CaseSensitiveVolume CaseSensitiveVolume.dmg
hdiutil attach CaseSensitiveVolume.dmg
cd /Volumes/CaseSensitiveVolume/
```

Put this repository in the case-sensitive volume

```sh
git clone https://github.com/TakumaKira/linux-kernel-dev.git
cd linux-kernel-dev
```

Clone the linux kernel repository

```sh
git clone https://github.com/torvalds/linux.git
```

Create a docker image for linux kernel development

```sh
docker build -t linux-kernel-dev .
```

Run the container

```sh
cd linux
docker run -it --rm -v "$(pwd):/kernel" linux-kernel-dev bash
```

Generate a defconfig file

```shell (linux-kernel-dev)
make ARCH=arm64 defconfig
```

Build the kernel

```shell (linux-kernel-dev)
make -j$(nproc)
```

Steps Using gbionescu/build-rootfs:
Clone the repository:

```sh
git clone https://github.com/gbionescu/build-rootfs.git
cd build-rootfs
```

Run the script to generate a root filesystem:

```sh
./build-rootfs.sh ubuntu
```

Replace ubuntu with your desired distribution type (e.g., alpine, debian, etc.).

This will create a sparse ext4 image (rootfs.ext4) containing the root filesystem.

Rename or move the generated image:

```sh
mv rootfs.ext4 rootfs.img
```

You can now use this rootfs.img with QEMU.

Install QEMU

```sh
brew install qemu
``` 

In /linux directory, run QEMU with your compiled kernel:

```sh
cd linux
qemu-system-aarch64 \
  -machine virt \
  -cpu cortex-a72 \
  -kernel arch/arm64/boot/Image \
  -append "console=ttyAMA0 root=/dev/vda1" \
  -drive file=rootfs.img,format=raw,if=virtio \
  -nographic
```