# Copyright 2024 Efabless Corporation
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
  lib,
  libparse,
  stdenv,
  python3,
  makeWrapper,
  ncurses,
  coreutils-full,
  gnugrep,
  gnused,
  gnutar,
  gzip,
  git,
  bash,
  klayout-pymod,
  yosys,
  opensta-stable,
  openroad,
  klayout,
  netgen,
  magic-vlsi,
  verilog,
  verilator,
  volare,
  tclFull,
}: let
  pyenv = python3.withPackages (ps:
    with ps; [
      libparse
      click
      pyyaml
      XlsxWriter
      klayout-pymod
      volare
    ]);
  pyenv-sitepackages = "${pyenv}/${pyenv.sitePackages}";
in
  stdenv.mkDerivation rec {
    pname = "openlane1";
    version = "1.1.1";
    
    src = [
      ./flow.tcl
      ./scripts
      ./configuration
      ./dependencies
    ];

    unpackPhase = ''
      echo $src
      for file in $src; do
        BASENAME=$(python3 -c "import os; print('$file'.split('-', maxsplit=1)[1], end='$EMPTY')")
        cp -r $file $PWD/$BASENAME
      done
      ls -lah
    '';

    passthru = {
      pyenv = pyenv;
    };

    includedTools = [
      yosys
      opensta-stable
      openroad
      klayout
      netgen
      magic-vlsi
      verilog
      verilator
      tclFull
    ];

    propagatedBuildInputs =
      includedTools
      ++ [
        pyenv
        ncurses
        coreutils-full
        gnugrep
        gnused
        bash
        gnutar
        gzip
        git
      ];

    nativeBuildInputs = [makeWrapper];

    installPhase = ''
      mkdir -p $out/bin
      cp -r * $out/bin
      wrapProgram $out/bin/flow.tcl\
        --set PATH ${lib.makeBinPath propagatedBuildInputs}\
        --set PYTHONPATH ${pyenv-sitepackages}
    '';

    doCheck = true;

    computed_PATH = lib.makeBinPath propagatedBuildInputs;

    meta = with lib; {
      description = "RTL-to-GDSII flow for application-specific integrated circuits (ASIC)s";
      homepage = "https://efabless.com/openlane";
      mainProgram = "flow.tcl";
      license = licenses.asl20;
      platforms = platforms.linux ++ platforms.darwin;
    };
  }
