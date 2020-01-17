# ~/.bashrc: executed by bash(1) for non-login shells.

# You may uncomment the following lines if you want `ls' to be colorized:
# export LS_OPTIONS='--color=auto'
# eval "`dircolors`"
# alias ls='ls $LS_OPTIONS'
# alias ll='ls $LS_OPTIONS -l'
# alias l='ls $LS_OPTIONS -lA'
#
# Some more alias to avoid making mistakes:
# alias rm='rm -i'
# alias cp='cp -i'
# alias mv='mv -i'

EDITOR=vim

exitstatus() {
  if [[ $? == 0 ]]; then
    echo -e "\e[92m"
  else
    echo -e "\e[91m"
  fi
}

export PS1='\[$(exitstatus)\]>\[\e[39m\] '
export PS2="> "

# Add ./.local/bin to PATH to simplify execution of pip-installed packages
PATH="${HOME}/.local/bin:${PATH}"

# NOTE: Add your customizations to ./.bashrc-personal.
source ~/.bashrc-personal
