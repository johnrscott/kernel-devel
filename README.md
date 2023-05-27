# Kernel development environment for emacs

Most of this repository will only work if the environment is properly sourced. From the root of the repository, run:

```bash
. setup-env.sh
```

That will add the `bin/` folder to your path, and provide a version of emacs (separate from your normal version if you have one) that is configured for kernel development. The configuration for emacs is located in the `emacs/` folder (which will not interfere with the normal user emacs configuration located in `~/.config/emacs/`). Note that this will not work if there exists `~/.emacs` or `~/.emacs.d`, because these configurations cannot be overridden. Replace `~/.emacs` with `~/.config/emacs/init.el` (and delete, or move, `.emacs.d`).

## Directory conventions

The `src/` directory will contain the linux kernel source tree, buildroot, gcc, and other tools that are required. Scripts in `bin/` refer to this directory for this purpose. Currently, the scripts refer to `src/linux-6.3.2`. Obtain it from 

## Building root

Use buildroot to create a root directory filesystem image. Mount it, and copy its contents to a folder called `root` in the top level of the repository. You can use commands like the following to install to a different root tree.

```bash
# From the repo dir
mkdir root
sudo mount src/buildroot/output/images/rootfs.ext4 root

# Now got to src/linux-6.3.2/
cd src/linux-6.3.2
INSTALL_MOD_PATH=../../root sudo -E make modules_install
INSTALL_PATH=../../root/boot/ sudo -E make install
sudo mkdir ../../root/boot
sudo make headers_install ARCH=x86 INSTALL_HDR_PATH=../../root/usr
```

Make a folder `root/boot/grub` and add

```conf
# Set the grub screen timeout. By setting to 0,
# the top option will be immediately selected
set timeout=2

# Make a menu entry for the operating system
menuentry linux {
	  linux /boot/vmlinuz-6.3.2 root=/dev/sda rw console=ttyS0,115200 acpi=off nokaslr
}
```

Next, package the whole root folder into an ISO image using

```bash
sudo grub-mkrescue root/ -o linux.iso
```

You can run the image using

```bash
# From root of repository
qemu-system-x86_64 -cdrom linux.iso -hda src/buildroot/output/images/rootfs.ext4
```

## Compiling the C compiler

The goal is to build the kernel with the same version of gcc that is installed into the built root, with the aim of being able to compile programs for this target without worrying about incompatibilities between this environment and gcc in the host.

First, download binutils from  https://mirror.koddos.net/gnu/binutils/: 

```bash
cd src/
wget https://mirror.koddos.net/gnu/binutils/binutils-2.40.tar.xz
cd binutils-2.40
```

Set the prefix to the `gcc_overlay` (which will be incorporated into root by buildroot):

```bash
export PREFIX=$(repo_dir)/gcc_overlay

# Get the target triple of your host machine by running gcc gcc -dumpmachine.
export TARGET=x86_64-linux-gnu
```

Make a build directory `src/binutils-2.40-build`, change into it, and configure and build:

```bash
cd src/
mkdir binutils-2.40-build
cd binutils-2.40-build
../binutils-2.40/configure --target=$TARGET \
	--prefix="$PREFIX" --with-sysroot \
	--disable-nls --disable-werror

make -j8
make install
```

Next, obtain gcc from https://ftp.gnu.org/gnu/gcc/:

```bash
wget https://ftp.gnu.org/gnu/gcc/gcc-13.1.0/gcc-13.1.0.tar.xz
tar xvf gcc-13.1.0.tar.xz
```

Ensure that `$PREFIX` and `$TARGET` are set, and that `gcc_overlay/bin` is in the path. Create a build directory for gcc, configure, and build:

```bash
mkdir gcc-13.1.0-build
cd gcc-13.1.0-build

../gcc-13.1.0/configure --target=$TARGET \
	--prefix="$PREFIX" --disable-multilib

make -j8
make install
```

## Compiling glibc

The C library for GNU/Linux systems is glibc. Download a recent version from https://ftp.gnu.org/gnu/glibc/ and extract it in the source directory:

```bash
cd src/
wget https://ftp.gnu.org/gnu/glibc/glibc-2.37.tar.xz
tar xvf glibc-2.37.tar.xz
```

## Other

Extracting patchsets from notmuch: https://github.com/aaptel/notmuch-extract-patch/tree/master
