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
#
time make -j8
```
