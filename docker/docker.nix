# Copyright 2023-2024 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
{
  dockerTools,
  buildEnv,
  python3,
  openlane1,
  system,
  coreutils-full,
  findutils,
  bashInteractive,
  gnugrep,
  gnused,
  gnumake,
  gdb,
  lldb,
  which,
  cacert,
  iana-etc,
  git,
  neovim,
  zsh,
  silver-searcher,
}:

assert builtins.elem system ["x86_64-linux" "aarch64-linux"];
 
let
  openlane-env-sitepackages = "${openlane1.pyenv}/${openlane1.pyenv.sitePackages}";
  openlane-env-bin = "${openlane1.pyenv}/bin";
  docker-arch-name = if system == "x86_64-linux" then
    "amd64"
  else
    "arm64v8"
  ;
in
  dockerTools.buildImage rec {
    name = "efabless/openlane";
    tag = "current-${docker-arch-name}";

    copyToRoot = buildEnv {
      name = "image-root";
      paths = [
        # Base OS
        ## GNU
        coreutils-full
        findutils
        bashInteractive
        gnugrep
        gnused
        which
        gnumake

        ## Networking
        cacert
        iana-etc

        # Conveniences
        git
        neovim
        zsh
        silver-searcher
        gdb
        lldb

        # OpenLane
        openlane1
      ];

      postBuild = ''
        mkdir -p $out/tmp
        mkdir -p $out/etc
        mkdir -p $out/usr/bin
        ln -s /bin/env $out/usr/bin/env
        
        cat <<HEREDOC > $out/etc/zshrc
        autoload -U compinit && compinit
        autoload -U promptinit && promptinit && prompt suse && setopt prompt_sp
        autoload -U colors && colors

        export PS1=$'%{\033[31m%}OpenLane Container%{\033[0m%}:%{\033[32m%}%~%{\033[0m%}%% ';
        HEREDOC
      '';
    };

    created = "now";
    config = {
      Cmd = ["/bin/env" "zsh"];
      WorkingDir = "/openlane";
      Env = [
        "LANG=C.UTF-8"
        "LC_ALL=C.UTF-8"
        "LC_CTYPE=C.UTF-8"
        "EDITOR=nvim"
        "PYTHONPATH=${openlane-env-sitepackages}"
        "PATH=${openlane-env-bin}:${openlane1.computed_PATH}:/bin"
        "TMPDIR=/tmp"
      ];
    };
  }
