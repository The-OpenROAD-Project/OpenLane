# Copyright 2023 Efabless Corporation
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
  createDockerImage,
  system,
  pkgs,
  lib,
  python3,
  openlane1,
  git,
  neovim,
  zsh,
  silver-searcher,
  coreutils,
}:
assert builtins.elem system ["x86_64-linux" "aarch64-linux"]; let
  docker-arch-name =
    if system == "x86_64-linux"
    then "amd64"
    else "arm64v8";
in (createDockerImage {
  inherit pkgs;
  inherit lib;
  name = "efabless/openlane";
  tag = "current-${docker-arch-name}";
  extraPkgs = with dockerTools; [
    git
    zsh
    neovim
    silver-searcher

    openlane1
    openlane1.pyenv
  ];
  nixConf = {
    extra-experimental-features = "nix-command flakes repl-flake";
  };
  maxLayers = 2;
  channelURL = "https://nixos.org/channels/nixos-24.05";

  image-created = "now";
  image-extraCommands = ''
    mkdir -p ./etc
    ln -s ${openlane1}/bin ./openlane1
    cat <<HEREDOC > ./etc/zshrc
    autoload -U compinit && compinit
    autoload -U promptinit && promptinit && prompt suse && setopt prompt_sp
    autoload -U colors && colors

    export PS1=$'%{\033[31m%}OpenLane Container (${openlane1.version})%{\033[0m%}:%{\033[32m%}%~%{\033[0m%}%% ';
    HEREDOC
  '';
  image-config-cwd = "/openlane";
  image-config-cmd = ["${zsh}/bin/zsh"];
  image-config-extra-path = [
    "/openlane"
    openlane1.computed_PATH
  ];
  image-config-extra-env = [
    "LANG=C.UTF-8"
    "LC_ALL=C.UTF-8"
    "LC_CTYPE=C.UTF-8"
    "EDITOR=nvim"
    "TMPDIR=/tmp"
  ];
})
