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

Testing with QEMU
You can use QEMU within Docker or on your host system to boot and test your custom kernel:

Install QEMU on your host (brew install qemu on macOS) or inside Docker.

Run QEMU with your compiled kernel:

```sh
qemu-system-aarch64 -machine virt -cpu cortex-a72 -kernel arch/arm64/boot/Image -append "console=ttyAMA0" -nographic
```