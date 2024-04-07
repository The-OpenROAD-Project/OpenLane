{
  openlane,
  lib,
  libparse,
  stdenv,
  python3,
  makeWrapper,
  ncurses,
  coreutils-full,
  gnugrep,
  gnused,
  bash,
  klayout-pymod
}:
let
  pyenv = (python3.withPackages (ps: with ps; [
    libparse
    click
    pyyaml
    XlsxWriter
    klayout-pymod
  ]));
  pyenv-sitepackages = "${pyenv}/${pyenv.sitePackages}";
in
  stdenv.mkDerivation rec {
    name = "openlane1";
    version = "1.0.0";
    
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

    propagatedBuildInputs = openlane.includedTools ++ [
      pyenv
    ];
    
    buildInputs = [
      ncurses
      coreutils-full
      gnugrep
      gnused
      bash
    ];
    
    nativeBuildInputs = [makeWrapper];
    
    installPhase = ''
      mkdir -p $out/bin
      cp -r * $out/bin
      wrapProgram $out/bin/flow.tcl\
        --set PATH ${lib.makeBinPath (propagatedBuildInputs ++ buildInputs)}\
        --set PYTHONPATH ${pyenv-sitepackages} 
    '';
    
    doCheck = true;
    
    computed_PATH = lib.makeBinPath (propagatedBuildInputs);
    
    meta = with lib; {
      description = "RTL-to-GDSII flow for application-specific integrated circuits (ASIC)s";
      homepage = "https://efabless.com/openlane";
      mainProgram = "flow.tcl";
      license = licenses.asl20;
      platforms = platforms.linux ++ platforms.darwin;
    };
  }
