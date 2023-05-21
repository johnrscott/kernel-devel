#!/usr/bin/env bash

if [[ ! -z "$KDEV_ENABLED" ]]; then
    echo "Kernel development environment is already enabled"
    return
fi

export KDEV_ENABLED=1

# https://stackoverflow.com/questions/59895/
# how-do-i-get-the-directory-where-a-bash-script
# -is-located-from-within-the-script
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# https://www.gnu.org/software/emacs/manual/
# html_node/emacs/Find-Init.html
export XDG_CONFIG_HOME=$SCRIPT_DIR
export PS1="\[\e[43m\]KDEV\[\e[m\] $PS1"
export PATH=$SCRIPT_DIR/bin:$PATH

echo "Kernel development environment enabled"
