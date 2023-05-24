# Kernel development environment for emacs

Add the path to the `bin/` folder to your bashrc (or equivalent):

```bash
export PATH=/path/to/kernel-devel/bin:$PATH
```

This adds `kemacs` to the path, which is just emacs with a custom configuration located in the `emacs/` folder (which will not interfere with the normal user emacs configuration located in `~/.config/emacs/`). Note that `kemacs` will not work if there exists `~/.emacs` or `~/.emacs.d`, because these configurations cannot be overridden. Replace `~/.emacs` with `~/.config/emacs/init.el` (and delete ``

## Info

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



## Other

Extracting patchsets from notmuch: https://github.com/aaptel/notmuch-extract-patch/tree/master
