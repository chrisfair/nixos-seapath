{ lib, stdenv, fetchzip, gettext, git, nodejs_18, python3 }:

stdenv.mkDerivation rec {
  pname = "cockpit-machines";
  version = "331";

  src = fetchzip {
    url = "https://github.com/cockpit-project/cockpit-machines/releases/download/${version}/cockpit-machines-${version}.tar.xz";
    sha256 = "96e477d5098d76a77bb19348c3e95ca1477ecabfd1497d8b08722d843187659e";
  };

  nativeBuildInputs = [
    git
    nodejs_18
    gettext
    python3
  ];

  makeFlags = [ "PREFIX=" "DESTDIR=$(out)" ];

  postPatch = ''
    substituteInPlace Makefile --replace /usr/share $out/share
    touch pkg/lib/cockpit.js
    touch pkg/lib/cockpit-po-plugin.js
    touch dist/manifest.json
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/cockpit/machines
    cp -r dist/* $out/share/cockpit/machines
    runHook postInstall
  '';

  postFixup = ''
    if [ -f "$out/share/cockpit/machines/index.js.gz" ]; then
      gunzip "$out/share/cockpit/machines/index.js.gz"
    fi

    if [ -f "$out/share/cockpit/machines/index.js" ]; then
      sed -i "s#/usr/bin/python3#/usr/bin/env python3#g" "$out/share/cockpit/machines/index.js"
      sed -i "s#/usr/bin/pwscore#/usr/bin/env pwscore#g" "$out/share/cockpit/machines/index.js"
      gzip -9 "$out/share/cockpit/machines/index.js"
    fi
  '';

  dontBuild = true;

  meta = with lib; {
    description = "Cockpit UI for virtual machines";
    homepage    = "https://github.com/cockpit-project/cockpit-machines";
    license     = licenses.lgpl21;
    platforms   = platforms.linux;
  };
}

