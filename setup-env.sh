#!/usr/bin/env bash

if [[ ! -z "$KDEV_ENABLED" ]]; then
    echo "Kernel development environment is already enabled"
    return
fi

export KDEV_ENABLED=1

# Full name for commits and emails
export FULL_NAME="John Scott"

# Anything that works with mbsync should be
# fine. Only tested gmail
export EMAIL_ADDRESS="johnrscott0@gmail.com"

# https://stackoverflow.com/questions/59895/
# how-do-i-get-the-directory-where-a-bash-script
# -is-located-from-within-the-script
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

export PATH=$SCRIPT_DIR/bin:$SCRIPT_DIR/sysroot/bin/:$PATH

# This is better as an environment variable than a command. Refactor.
export REPO_DIR=$(repo_root)

export CONFIG=$REPO_DIR/.config
mkdir -p $CONFIG

# https://www.gnu.org/software/emacs/manual/
# html_node/emacs/Find-Init.html
export XDG_CONFIG_HOME=$SCRIPT_DIR
export PS1="\[\e[43m\]KDEV\[\e[m\] $PS1"

# See man git-config
export GIT_CONFIG_GLOBAL=$CONFIG/gitconfig

# Alias commands; mainly to point to the local
# config files.
alias mbsync="mbsync -c $CONFIG/mbsyncrc"
alias msmtp="msmtp -C $CONFIG/msmtprc"
alias cdlinux='cd $REPO_DIR/src/linux-$(kernel_version)'

# Perform initial configurations of applications
# Can be safely called multiple times
init_gitconfig

echo "Kernel development environment enabled"
