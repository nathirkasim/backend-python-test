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

# Create venv if not already created
if [[ ! (-d .venv && -f .venv/bin/activate) ]]; then
  python -m venv .venv
else
  echo -e "Using a previously created venv at ./.venv"
fi

source .venv/bin/activate

# Load personal Bash config from ./.bashrc-personal. if available
if [[ -f ~/.bashrc-personal ]]; then
  source ~/.bashrc-personal
else
  echo -e "No personal bashrc found at ~/.bashrc-personal"
fi
