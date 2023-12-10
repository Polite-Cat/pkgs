{ lib
, stdenv
, fetchurl
, dpkg
, wrapGAppsHook
, autoPatchelfHook
, clash-meta
, openssl
, webkitgtk
, udev
, libayatana-appindicator
}:

stdenv.mkDerivation rec {
  pname = "clash-fuck";
  version = "1.0.0";

  src = fetchurl {
    url = "https://hack-store-1257337367.cos.ap-nanjing.myqcloud.com/clash-fuck_${version}_amd64.deb";
    hash = "sha256-53uk69x11Ul6uWnqUnjZhhf3q6bupqBevVmuEWMlFUI=";
  };

  nativeBuildInputs = [
    dpkg
    wrapGAppsHook
    autoPatchelfHook
  ];

  buildInputs = [
    openssl
    webkitgtk
    stdenv.cc.cc
  ];

  runtimeDependencies = [
    (lib.getLib udev)
    libayatana-appindicator
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mv clash-fuck/usr/* $out/

    runHook postInstall
  '';
}
