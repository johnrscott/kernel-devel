# Kernel development environment for emacs

Some script examples in this repository will only work if the environment is properly sourced. From the root of the repository, run:

```bash
. setup-env.sh
```

That will add the `bin/` folder to your path, and provide a version of emacs (separate from your normal version if you have one) that is configured for kernel development. The configuration for emacs is located in the `emacs/` folder (which will not interfere with the normal user emacs configuration located in `~/.config/emacs/`). Note that this will not work if there exists `~/.emacs` or `~/.emacs.d`, because these configurations cannot be overridden. Replace `~/.emacs` with `~/.config/emacs/init.el` (and delete, or move, `.emacs.d`).

## Directory conventions

The `src/` directory will contain the linux kernel source tree and buildroot.

## Building a root directory

Following [this guide](https://medium.com/@daeseok.youn/prepare-the-environment-for-developing-linux-kernel-with-qemu-c55e37ba8ade), set up buildroot as follows:

```bash
cd $(repo_root)/src/
wget https://buildroot.org/downloads/buildroot-2023.02.1.tar.gz
tar xvf buildroot-2023.02.1.tar.gz
cd buildroot-2023.02.1/
make menuconfig
```

In *Target Architecture*, specify `x86_64`. In *Filesystem images*, choose *ext2/3/4 root filesystem* and select `ext4` as the variant. Save and exit. Build using

```bash
# 37m2.928s
time make -j8
```

## Building the kernel

```bash
cd src/linux-6.3.4
make tinyconfig
make menuconfig
```

Set the following configuration (`configs/config-6.3.4-minimal`)

- *64-bit kernel* (`64BIT`). 
- *Enable support for printk* (`PRINTK`). *Enable TTY* (`TTY`). These two options are required to see boot messages when running qemu in graphical mode.
- *8250/16550 and compatible serial support* (`SERIAL_8520`), *Console on 8250/16550 and compatible serial port* (`SERIAL_8520_CONSOLE`). These options are required when passing `-serial stdio -display none` to qemu and using the linux kernel command line option `console=ttyS0,115200` to redirect qemu text output to the console.

Build time (`time make -j8`) with tinyconfig alone is 0m50.392s. The full config build time for `config-6.3.4-minimal` is 0m56.558s. This boots with the `run_kernel` script to a kernel panic, because filesystem support for the ext4 buildroot image is missing.

