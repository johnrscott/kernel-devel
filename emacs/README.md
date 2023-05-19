# Emacs Configuration

This repository contains emacs configuration. 


## Before opening emacs for the first time

If you are coming from using `~/.emacs` and `~/.emacs.d`, delete (or move) those two files before opening emacs for the first time. You are aiming to have a folder `~/.config/emacs`. The first time you open emacs, emacs will look for the main configuration file `~/.config/emacs/init.el` (the equivalent of `~/.emacs`). All packages will be installed automatically. Some of the packages have system dependencies (i.e. installed with apt). You do not need to install these before opening emacs for the first time (but you will need to install them before their respective features work).

## Installing system dependencies

This .emacs file is designed for at least emacs27. Before
Ubuntu 22.04, you need to use this:

```bash
sudo apt remove --autoremove emacs emacs-common
sudo add-apt-repository ppa:kelleyk/emacs
sudo apt update
sudo apt install emacs28
```

On Ubuntu 22.04, you have emacs27 from the package manager.

All emacs packages are installed automatically the first time you open emacs. However, you need to install the following dependencies manually for this configuration to work:

* vterm
  - cmake and libtool for compiling vterm
  ```bash
  sudo apt install cmake libtool-bin
  ```
* Git
  - git 
  ```bash
  sudo apt install git
  ```
* Flyspell
  - aspell
  ```bash
  sudo apt install aspell
  ```
* Rust
  - The Rust language (rustup)
  - The rust source (rustup component add rust-src)
  - rust-analyzer from source
    (https://robert.kra.hn/posts/rust-emacs-setup/)
* C/C++
  - clangd for c/c++ code linting
  ```bash
  sudo apt install clangd-12
  ```
* Python3
  - pyright is the python language server (there are also others, consult reddit)
  ```bash
  python3 -m pip install pyright
  ```
* Julia
  - julia (install via juliaup)
* R
  - languageserver
  ```r
  install.packages("languageserver"))
  ```
* Verilog
  - hdl_checker
  ```bash
  python3 -m pip install hdl_checker
  ```
  - or, svlangserver
  ```bash
  npm install -g @imc-trading/svlangserver)
  ```

Each section contains a cheatsheet of useful commands
relating to the mode. See below for details.

## Cleaning the emacs folder

When you open emacs for the first time, this folder will be populated with a number of other folders (it is playing the role of `.emacs.d`). Run `clean.sh` to remove these folders. In particular, this will remove all packages (the `elpa/` directory), and custom set variables (`custom.el`).
