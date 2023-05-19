;; DEPENDENCIES YOU NEED
;;
;; This .emacs file is designed for at least emacs27. Before
;; Ubuntu 22.04, you need to use this:
;;
;; sudo apt remove --autoremove emacs emacs-common
;; sudo add-apt-repository ppa:kelleyk/emacs
;; sudo apt update
;; sudo apt install emacs28
;;
;; On Ubuntu 22.04, you have emacs27 from the package manager.
;;
;; All emacs packages are installed automatically the first
;; time you open emacs (you can delete the .emacs.d directory
;; at any tiem and repeat the process). However, you need to
;; install the following dependencies manually for this
;; configuration to work. Once you have everything installed,
;; the configuration should work.
;;
;; * vterm
;;   - libtool (sudo apt install libtool-bin)
;;
;; * Rust
;;   - The Rust language (rustup)
;;   - The rust source (rustup component add rust-src)
;;   - rust-analyzer from source
;;     (https://robert.kra.hn/posts/rust-emacs-setup/)
;;
;; * C/C++
;;   - clangd (sudo apt install clangd-12)
;;
;; * Python3
;;   - pyright (python3 -m pip install pyright)
;;
;; * Git
;;   - git (sudo apt install git)
;;
;; * Flyspell
;;   - aspell (sudo apt install aspell)
;;
;; Each section contains a cheatsheet of useful commands
;; relating to the mode. See below for details.
;;

;; ORGANISATION OF THIS FILE 
;;
;; Generic emacs settings (basic settings that apply to
;; default emacs, no packages) go at the top. Automatic
;; dependency setup comes next. After that, configurations
;; are listed roughly in order of what has the most reach.
;; For example, LSP mode applies to nearly everything, so
;; it is listed up front; similarly, git setup comes soon
;; after. All the configurations for particular languages
;; come next (Rust, C/C++, Python, etc). Finally, simple
;; one-liner packages (like YAML and JSON mode) are configured
;; last.
;;
;; RECOMMENDATIONS
;;
;; This file mostly sticks to the defaults. This keeps
;; things working properly -- mostly the default keybindings
;; and behaviour are sensible. If you change something,
;; try to change it within its own scope (e.g. make C++
;; changes in the C++ section, not the LSP section).

;; BEGIN CONFIGURATION
;;

;; Don't write custom-set-variables to this file (it is put
;; inside .emacs.d instead)
(setq custom-file (concat user-emacs-directory "custom.el"))
(load custom-file 'noerror)

;; GENERIC EMACS
;;
;; Put any generic emacs configuration you want here.
;; Feel feel to change anything to your tastes. Try to
;; keep it to simple settings that are relatively
;; independent of other more complicated setups (for
;; example, go careful setting random keybindings that
;; could break other things further down). In particular,
;; don't do anything that involves packages (that must
;; go below the automatic dependency section.
;;
(setq inhibit-startup-screen t)
(menu-bar-mode -1)
(toggle-scroll-bar -1)
(tool-bar-mode -1)
(global-visual-line-mode 1)

;; AUTOMATIC DEPENDENCY INSTALLATION
;;
;; NOTE: if you ever get MELPA-related errors while trying to
;; install a package, it is highly likely refreshing the package
;; archive will fix it (especially if you haven't done it in
;; a while): run M-x `package-refresh-packages`.
;;
;; use-package manages installation of dependencies if they are missing.
;; In this section, use-package is installed if it is not present, and
;; then all packages are installed later with use-package.
;;
;; Only emacs packages will be automatically installed, however, there
;; are also dependencies on other libraries. 
;;
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Install use-package to automate other package installation
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; CHOOSE A THEME
;;
;; You may be interested in the following:
;;
;; C-c d - Toggle dark theme (swaps between the dracula theme
;;         and the default light theme)
;;
;; It will get installed and enabled automatically.
(defun toggle-dark-theme ()
  "Toggle between dark/light themes"
  (interactive)
  (if custom-enabled-themes
      (disable-theme 'dracula)
    (load-theme 'dracula t)))

(use-package dracula-theme
  :ensure
  :config
  (toggle-dark-theme))

;; VTERM CONFIGURATION
;;
;; You may be interested in the following:
;;
;; C-<return> - Send a line from the current buffer
;;              to a vterm. Useful for scripting
;;              languages lacking a built-in mode
;; C-c t - open a new vterm on the right and give it
;;         focus. Works in any mode.
;; C-c C-t - Toggle copy mode. In copy mode, you can
;;           scroll the vterm buffer like a normal window,
;;           and select and copy text.
;;
;; Unlike other packages in this file, vterm will
;; only be installed when it is first loaded (defer).
;; This is because it prompts you to compile the terminal,
;; which would hold up the process of opening emacs for
;; the first time (say, if you tried to go away and make
;; a coffee while it did it). 
;;
;;
(use-package vterm
  :ensure
  :defer)

(require 'bind-key)
(bind-key* "C-c t" 'make-new-vterm)

(load-file (expand-file-name "lisp/vterm.el" user-emacs-directory))

;; LSP MODE CONFIGURATION
;;
;; All lsm-mode commands begin with the prefix C-c l.
;; The following shortcuts may be of interest to you:
;;
;; C-c l G g - bring up a window showing the definition of the
;;               item under the cursor
;; C-c l g r - find all references to the item under the cursor (q to exit)
;; C-c l r r - rename the symbol under the cursor throughout project
;; C-c l a a - If LSP mode has a code suggestion for a wiggly red line,
;;               implement the suggestion.
;;
;; lsp-workspace-removce-all-folders - remove the LSP root directory of
;;    the project (you will be prompted next time to set the project
;;    folder again)
;;
;; There are loads of shortcuts. The best thing to do is run
;; C-c l ? to see the list
;;
(use-package lsp-mode
  :ensure
  :init
  (setq lsp-keymap-prefix "C-c l")
  :hook (c-mode c++-mode python-mode)
  :commands lsp)

;; LSP UI MODE CONFIGURATION
;;
;; You may be interested in the following keybindings:
;;
;; M-. - Jump to definition
;; M-? - List references (i.e. opposite to the above)
;;
(use-package lsp-ui
  :ensure
  :commands lsp-ui-mode
  :custom
  (lsp-ui-peek-always-show t)
  (lsp-ui-sideline-show-hover t)
  (lsp-ui-doc-enable t)
  (lsp-ui-imenu-auto-refresh))

(use-package company
  :ensure)

(use-package yasnippet
  :ensure
  :config
  (yas-reload-all)
  (add-hook 'prog-mode-hook 'yas-minor-mode)
  (add-hook 'text-mode-hook 'yas-minor-mode))

(use-package flycheck
  :ensure)

;; MAGIT (GIT) CONFIGURATION
;;
;; You may be interested in the following:
;;
;; C-x g - Open the git status window (q to close)
;; 
;; From the git status window, you can commit all
;; files by typing c, and then -a. (Just follow
;; the onscreen instructions). Next, press c,
;; write the commit message, and press C-c C-c
;; to finish the commit. Press P p (inside the
;; status window) to push. If you want to stage
;; everything, press S. To unstage a file, press
;; u, or to unstage all, press U.
;;
(use-package magit
  :ensure)

;; RUST CONFIGURATION
;;
;; This configuration is taken from https://robert.kra.hn/posts/rust-emacs-setup/.
;; The only part that is not currently set up is the debugger.
;;
(use-package rustic
  :ensure)

;; C/C++ CONFIGURATION
;;
;; You may be interested in the following:
;;
;; C-c m - compile for the first time (specify
;;         a command to use). Opens the compile
;;         window in a new buffer.
;; C-c c - recompile using the same command as
;;         before.
;;
(use-package cc-mode
  :mode ("\\.tpp\\'" . c++-mode)
  :bind (("C-c m" . compile)
	 ("C-c c" . recompile))
  :config
  (setq-default c-basic-offset 8)
  (setq c-default-style "linux")
  (setq c-noise-macro-names '("constexpr")))


;; PYTHON CONFIGURATION
;;
;; pyright is a language server for python.
;;
(use-package lsp-pyright
  :ensure)

;; JULIA CONFIGURATION
;;
;; You may be interested in the following:
;;
;; C-RET - Run the line under the cursor. Will
;;         automatically open a julia REPL.
;;
;; C-c C-c - Run a selected block of code
;;
;; Be aware that the start-up time for the LSP
;; language server is on the order 30-40 seconds.
;; Keep an eye on the LSP starting/connected
;; info at the bottom of the screen. After it has
;; connected, there is a further delay of about
;; 10 seconds before autocomplete etc.
;;
(use-package julia-mode
  :ensure)

(use-package julia-repl
  :ensure
  :hook (julia-mode))

(use-package lsp-julia
  :ensure)

;; R CONFIGURATION
;;
;; You may be interested in the following:
;;
;; C-c C-w C-l - Load current package
;;
(use-package ess
  :ensure)

;; VERILOG CONFIGURATION
;;
;;

;; LATEX CONFIGURATION
;;
;; You may be interested in the following:
;;
;; C-c C-c - Compile the current document
;;
;; C-c C-s - Add a new section
;; C-c C-e - Add a new environment
;; C-c [   - Insert a citation
;; 
;;
;; C-c =   - View interactive table of contents
;;
;;
(defun default_to_latexmk ()
  (setq TeX-command-default "LatexMk"))

(use-package tex
  :ensure auctex
  :hook ((LaTeX-mode . reftex-mode)
	 (LaTeX-mode . default_to_latexmk))
  :config
  (setq font-latex-fontify-script nil))
  
;; LATEXMK CONFIGURATION
;;
;; To check things are working, you can call
;; latexmk on the command line at the location
;; of the main.tex. Use latexmk -C to clean.
;;
(use-package auctex-latexmk
  :ensure
  :config
  (auctex-latexmk-setup)
  (setq auctex-latexmk-inherit-TeX-PDF-mode t))

;; FLYSPELL CONFIGURATION
;;
;; Flyspell mode is configured to turn on in all
;; programming modes, where it checks comments and
;; strings. You may get some false-positives on
;; syntax, but overall it is worth it for having the
;; documentation spell-checked.
;;
;; Flyspell is also enabled for latex-mode and text
;; mode (which covers plain txt, org, etc.)
;;
;; You may be interested in the following:
;;
;; C-; - autocorrect previous word, keep pressing
;;         to cycle through options. Arrows to leave.
;; flyspell-buffer - run flyspell on the whole buffer
;;
;; Related, there is also ispell-buffer to run the
;; spell checker.
;;
;; Future work:
;;  - Look into wucuo
;; 
;; 
(use-package flyspell
  :ensure
  :hook ((LaTeX-mode)
	 (text-mode)
	 (prog-mode . flyspell-prog-mode)))


;; OTHER USEFUL PACKAGES
;;

(use-package yaml-mode
  :ensure)

(use-package json-mode
  :ensure)

(use-package cmake-mode
  :ensure)

(use-package toml-mode
  :mode "\\.sby\\'" ; For SymbiYosis configuration files
  :ensure)

(use-package tcl
  :ensure)

;; Global keybindings (for any mode)
(require 'bind-key)
(bind-key* "C-c d" 'toggle-dark-theme)
(bind-key* "C-<return>" 'vterm-execute-current-line)

;; Byte compile everything (makes a noticeable difference
;; to the startup time, down to 1s from about 5s from executing
;; "emacs" in bash to ready-to-type in emacs.
(byte-recompile-directory (expand-file-name user-emacs-directory) 0)
