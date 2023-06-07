# Kernel development environment for emacs

Some script examples in this repository will only work if the environment is properly sourced. From the root of the repository, run:

```bash
. setup-env.sh
```

That will add the `bin/` folder to your path, and provide a version of emacs (separate from your normal version if you have one) that is configured for kernel development. The configuration for emacs is located in the `emacs/` folder (which will not interfere with the normal user emacs configuration located in `~/.config/emacs/`). Note that this will not work if there exists `~/.emacs` or `~/.emacs.d`, because these configurations cannot be overridden. Replace `~/.emacs` with `~/.config/emacs/init.el` (and delete, or move, `.emacs.d`).

You can use the terminal (vterm) inside emacs for everything in this repository. Open emacs using by running `emacs` (after sourcing the `setup-env.sh` above). Then, you can open a terminal using `C-c t` (ctrl-c followed by t). Any time you want to send a line of code to execute in the terminal from any other buffer (e.g. from this readme), position the cursor anywhere on the line and run `C-<return>` (ctrl-enter). You can also highlight a group of lines and send them all to the terminal using `C-<return>`. Several other things (the menuconfig and qemu) can be run directly inside the emacs terminal as well.

To use ctags for navigating the kernel source code, install cscope as follows:

```bash
sudo apt install cscope
```

In the kernel source tree, run `make cscope` following by `make TAGS`. Emacs is already set up to use ctags. For example, you can run `C-c s s` to search for a symbol. Use `C-c s ?` to view the list of available commands. 

Emacs is also set up to use LSP-mode, if you install clangd:

```bash
sudo apt install clangd-12
```

You need to build the kernel, and then run the script `./scripts/clang-tools/gen_compile_commands.py`. You do not need to use clang for this to work. To test, try `C-c l g g` to jump to the definition of the symbol at the cursor. Run `C-c l ?` for other LSP commands.

## Helper scripts

Once you have sourced `setup-env.sh`, you can run the commands in `bin/` from anywhere. 

Use `kernel_version` to see the version of the kernel which will be used in other scripts, and `set_kernel_version` to set it. Then run `get_kernel` to download and unpack that version into `src/`. Run `menuconfig` to open the configuration for the current kernel. Use `build_kernel` to build the current kernel. You still need to download and build `buildroot` manually (see below). However, when all that is done, `run_kernel` will run the currently selected `kernel_version` in QEMU. Make sure qemu is installed first using:

```bash
sudo apt install qemu-system-x86
```

## Using ctags 

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
- *8250/16550 and compatible serial support* (`SERIAL_8250`), *Console on 8250/16550 and compatible serial port* (`SERIAL_8250_CONSOLE`). These options are required when passing `-serial stdio -display none` to qemu and using the linux kernel command line option `console=ttyS0,115200` to redirect qemu text output to the console.

Build time (`time make -j8`) with tinyconfig alone is 0m50.392s. The full config build time for `config-6.3.4-minimal` is 0m56.558s. This boots with the `run_kernel` script to a kernel panic, because filesystem support for the ext4 buildroot image is missing. Modify the following config:

- *Enable the block layer* (`CONFIG_BLOCK`). This enables the block device path in `mount_root()`.
- Enable *The Extended 4 (ext4) filesystem* (`CONFIG_EXT4_FS`). Also enable debugging for ext4.

QEMU emulates a particular computer system: the [i440f PCx](https://www.qemu.org/docs/master/system/i386/pc.html). This requires PCI and PIIX driver support, enabled by adding the following configuration options:

- *PCI Support* (`CONFIG_PCI`)
- *Serial ATA and Parallel ATA drivers (libata)* (`CONFIG_ATA`)
- *Intel ESB, ICH, PIIX3, PIIX4 PATA/SATA support* (`CONFIG_ATA_PIIX`)
- *SCSI disk support* (`CONFIG_BLOCK_DEV_SD`)

At this point, QEMU should detect the harddrive (`QEMU DVD-ROM, 2.5+, max UDMA/100`) correctly, and mount the root filesystem. This config is stored in `configs/config-6.3.4-qemu` However, there is still a kernel panic due to no working init; this is due to lack of ELF support (confirm by inspecting the return value of `search_binary_handler()` in `fs/exec.c`):

- *CONFIG_BINFMT_ELF* (`CONFIG_BINFMT_ELF`)

At this point, init will run. However, there is still support for the pseudo-filesystems `proc/` and `sys/` missing. Enable these as follows:

- */proc file system support* (`CONFIG_PROC_FS`)
- *sysfs file system support* (`CONFIG_SYSFS`)
- *Maintain a devtmpfs filesystem to mount at /dev* (`CONFIG_DEVTMPFS`) and *Automount devtmpfs at /dev, after the kernel mounted the rootfs* (`CONFIG_DEVTMPFS_MOUNT`)

This config is stored in `configs/config-6.3.4-sysfs`; up to this point, the compilation takes 1m35.674s. The `buildroot` init needs POSIX timers.

- *Posix Clocks and timers* (`CONFIG_POSIX_TIMERS`)

The config should now boot to a console (login username `root`, no password). The config is stored in `configs/config-6.3.4-console`. To use this configuration from clean, run the following commands:

```bash
set_kernel_version
# type 6.3.4 and press enter
get_kernel
set_config console
build_kernel

# Build buildroot first before running the kernel (see above).
run_kernel
```

## linux-next

The linux-next tree is a preview into the potential state of the kernel after the next merge window closes, as described in the [kernel documentation](https://docs.kernel.org/process/2.Process.html#next-trees). 

You can view the current state of the next tree on the [official repository page](https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git). This shows recent changes and tags.

The procedure for setting up linux-next is as follows (based the instructions [here](https://www.kernel.org/doc/man-pages/linux-next.html)):

```bash
# Clone the mainline linux repository. This is the latest version of 
# the linux development kernel, on which the linux-next changes will
# be superimposed.
cd $(repo_dir)/src/
git clone https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git linux-next
cd linux-next

# Add the linux-next remote, where the preview of upcoming kernel features
# is stored. Download the changes (but do not merge anything). Also download
# the tags. The branch is still set to master after this step
git remote add linux-next  https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git
git fetch linux-next
git fetch --tags linux-next

# View the next- tags. This shows the most recent tags. You can create
# a new branch based on any of these
git tag -l "next" | tail

# You can make a new branch based on one of these tags as follows
git checkout -b mybranch next-20230605
```

The notes below are based on the `mybranch` created above.

After make some changes to the branch, 


## Email setup

To set up the email client, install [offlineimap](https://www.offlineimap.org/) and [not much mail](https://notmuchmail.org/) as follows:

```bash
sudo apt install offlineimap3 notmuch
```

If you have a gmail account, make a configuration file `~/.offlineimaprc`, replacing the variables in braces as appropriate:

```ini
[general]
accounts = gmailaccount
 
[Account gmailaccount]
localrepository = localgmail
remoterepository = remotegmail
 
[Repository localgmail]
type = GmailMaildir
localfolders = $HOME/mail/{your_email_addr}@gmail.com
 
[Repository remotegmail]
type = Gmail
maxconnections=1
remotehost = imap.gmail.com
remoteuser = {your_email_addr}@gmail.com
remotepass = {email_app_pass}
ssl = yes
sslcacertfile = /etc/ssl/certs/ca-certificates.crt
```

The password `{email_app_pass}` is not your email password; it is an app password generated in your google settings. See [here](https://support.google.com/accounts/answer/185833?hl=en), or search for `google mail app password`. At the time I did it:

1. Go to your google account page (not gmail)
2. Navigate to Security, then 2-step verification, then app passwords
3. Create a new app; set the app to Mail and the device to Custom.
4. Click generate, and copy the password to the config file below.

Synchronise the mail directory by running `offlineimap`. 

Run `notmuch` to begin one-time configuration. Specify the mail directory. The configuration will be stored in `~/.notmuch-config`. Run `notmuch new` to synchronise new mail from `offlineimap`. 

To sync your mailbox, run

```bash
offlineimap
notmuch new
```

To open `notmuch` in emacs, run `M-x notmuch`.

## Rust development

Install `rustup` from the [official rust installation page](https://www.rust-lang.org/tools/install). Documentation about using rust in the kernel is provided [here](https://docs.kernel.org/rust/quick-start.html).


As documented [here](https://rust-lang.github.io/rustup/overrides.html#directory-overrides), individual directories can be configured to use their own toolchains. Set up the kernels toolchain preference using:

```bash
cd $(repo_dir)/src/linux-next
rustup override set $(scripts/min-tool-version.sh rustc)
```

Add the rust source code (for cross-compilation purposes) and install `bindgen` for the C bindings.

```bash
rustup component add rust-src
cargo install --locked --version $(scripts/min-tool-version.sh bindgen) bindgen
```

Install `clang`, and confirm that the rust setup is working:

```bash
sudo apt install clang
make LLVM=1 rustavailable
```

Copy the minimal configuration and enable the *Rust support* (`CONFIG_RUST`) option.

```bash
cp $(repo_dir)/configs/config-6.3.4-console .config
make menuconfig
make -j8
```

## Patches

To create a patchset based on all the commits from a particular commit to `HEAD`, run

```bash
git format-patch -o patch/ {commit}
```

This will create a directory called `patch` and put `.patch` files in it, one per commit, formatted as patch emails. You can open one of these files in emacs and view it in diff mode. You can apply it manually using `C-c C-a`. Note that the patch must be located at the head of the kernel source tree for this to work -- not in the `patch/` directory.
