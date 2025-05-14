{ lib, stdenv, fetchzip, gettext, git, nodejs_18, python3, pkg-config }:

stdenv.mkDerivation rec {
  pname = "cockpit-machines";
  version = "331";

  src = fetchzip {
    url = "https://github.com/cockpit-project/cockpit-machines/archive/refs/tags/${version}.tar.gz";
    sha256 = "0r52wl4ap4jwxy4p8j0pvs4r9jww1dp2n84j0y5vxl2wvz1nm0b6"; # Update via `nix-prefetch-url`
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
}

