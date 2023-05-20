# Kernel development environment for emacs

Add the path to the `bin/` folder to your bashrc (or equivalent):

```bash
export PATH=/path/to/kernel-devel/bin:$PATH
```

This adds `kemacs` to the path, which is just emacs with a custom configuration located in the `emacs/` folder (which will not interfere with the normal user emacs configuration located in `~/.config/emacs/`). Note that `kemacs` will not work if there exists `~/.emacs` or `~/.emacs.d`, because these configurations cannot be overridden. Replace `~/.emacs` with `~/.config/emacs/init.el` (and delete ``

## Of interest

Extracting patchsets from notmuch: https://github.com/aaptel/notmuch-extract-patch/tree/master
