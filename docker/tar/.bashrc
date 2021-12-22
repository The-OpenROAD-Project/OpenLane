# OpenLane .bashrc file
alias ll='ls -lAGFh';

export OL_GIT_VERSION=$(cat /git_version);

export PS1="\[\033[1;31m\]OpenLane Container ($OL_GIT_VERSION)\[\033[0m\]:\[\033[4;30m\]\w\[\033[0m\]$ ";