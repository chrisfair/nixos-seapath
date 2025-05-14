{ lib, stdenv, fetchzip, gettext, git, nodejs_18, python3, pkg-config }:

stdenv.mkDerivation rec {
  pname = "cockpit-machines";
  version = "331";

  src = fetchzip {
    url = "https://github.com/cockpit-project/cockpit-machines/archive/refs/tags/${version}.tar.gz";
    sha256 = "TCzXJAfWU3t696+dTBSen35SVhM7eiVJi4+b+DNb52M="; # Update via `nix-prefetch-url`
  };

  nativeBuildInputs = [
    gettext
    nodejs_18
    python3
    pkg-config
    git
  ];

  buildPhase = ''
    runHook preBuild
    make
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/cockpit/machines
    cp -r dist/* $out/share/cockpit/machines
    runHook postInstall
  '';

  meta = with lib; {
    description = "Cockpit UI for virtual machines";
    homepage    = "https://github.com/cockpit-project/cockpit-machines";
    license     = licenses.lgpl21;
    platforms   = platforms.linux;
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace 'git describe' 'echo "${version}"' \

      # Disable cockpit-po-plugin.js generation
      --replace 'git rev-parse --show-toplevel' '.' \
      --replace 'git log -1 --pretty=format:%ct' 'date +%s'
  '';
}

