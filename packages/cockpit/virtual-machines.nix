{ lib, stdenv, fetchzip, gettext }:

stdenv.mkDerivation rec {
  pname = "cockpit-machines";
  version = "331";

  src = fetchzip {
    url = "https://github.com/cockpit-project/cockpit-machines/archive/refs/tags/${version}.tar.gz";
    sha256 = "TCzXJAfWU3t696+dTBSen35SVhM7eiVJi4+b+DNb52M="; # Update via `nix-prefetch-url`
  };

  nativeBuildInputs = [ gettext ];

  makeFlags = [ "DESTDIR=$(out)" "PREFIX=" ];

  postPatch = ''
    substituteInPlace Makefile --replace /usr/share $out/share

    mkdir -p dist

    # Replace manifest.json with a working one
    cat > dist/manifest.json <<EOF
    {
      "module": "machines",
      "index": "index.html",
      "label": "Virtual Machines",
      "requires": ["cockpit", "libvirt"],
      "js": ["index.js"],
      "css": ["index.css"],
      "menu": {
        "vms": {
          "label": "Virtual Machines",
          "path": "index.html",
          "order": 60,
          "keywords": [
            { "matches": ["libvirt", "vm", "kvm", "qemu", "virtual"] }
          ]
        }
      }
    }
  EOF
    '';
 
  postFixup = ''
    if [ -f "$out/share/cockpit/machines/index.js.gz" ]; then
      gunzip $out/share/cockpit/machines/index.js.gz
    fi

    if [ -f "$out/share/cockpit/machines/index.js" ]; then
      sed -i "s#/usr/bin/python3#/usr/bin/env python3#ig" $out/share/cockpit/machines/index.js
      sed -i "s#/usr/bin/pwscore#/usr/bin/env pwscore#ig" $out/share/cockpit/machines/index.js
      gzip -9 $out/share/cockpit/machines/index.js
    fi
  '';

  installPhase = ''
    mkdir -p $out/share/cockpit/machines
    cp -r dist/* $out/share/cockpit/machines

    if [ -f "$out/share/cockpit/machines.index.js.gz" ]; then
      gunzip $out/share/cockpit/machines/index.js.gz
    fi 

    if [ -f "$out/share/cockpit/machines/index.css.gz" ]; then
      gunzip $out/share/cockpit/machines/index.css.gz
    fi
  '';

  dontBuild = true;

  meta = with lib; {
    description = "Cockpit UI for virtual machines";
    license = licenses.lgpl21;
    homepage = "https://github.com/cockpit-project/cockpit-machines";
    platforms = platforms.linux;
  };
}
