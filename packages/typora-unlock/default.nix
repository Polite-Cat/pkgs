{ stdenv
, fetchurl
, dpkg
, lib
, glib
, nss
, nspr
, at-spi2-atk
, cups
, dbus
, libdrm
, gtk3
, pango
, cairo
, xorg
, libxkbcommon
, mesa
, expat
, alsa-lib
, buildFHSEnv
, cargo
, unzip
}:

let
  pname = "typora";
  version = "1.7.6";
  src = fetchurl {
    url = "https://download.typora.io/linux/typora_${version}_amd64.deb";
    hash = "sha256-o91elUN8sFlzVfIQj29amsiUdSBjZc51tLCO+Qfar6c=";
  };
  fuck_src = fetchurl {
    url = "https://github.com/networm6/resources/archive/refs/heads/master.zip";
    sha256 = "sha256-M6pQicQ7S17vriik7gK1hQetczFrI7FrgZh1+tvlHX0=";
  };

  typoraBase = stdenv.mkDerivation {
    inherit pname version src fuck_src;

    nativeBuildInputs = [ dpkg cargo unzip ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      echo start
      echo $out
      pwd
      mkdir -p $out/bin $out/share 
      
      unzip -q $fuck_src
      echo unzipped
      mv resources-master/node_inject usr/share/typora/node_inject
      chmod a+x usr/share/typora/node_inject
      current_dir=$(pwd)
      cd ./usr/share/typora/ && ./node_inject
      cd "$current_dir"
      
      sed -i 's/感谢您的支持/仅供学习用途，侵删/' usr/share/typora/resources/locales/zh-Hans.lproj/Welcome.json
      echo statement
      
      mv usr/share $out
      echo moved      
      ln -s $out/share/typora/Typora $out/bin/Typora

      runHook postInstall
    '';
  };

  typoraFHS = buildFHSEnv {
    name = "typora-fhs";
    targetPkgs = pkgs: (with pkgs; [
      typoraBase
      udev
      alsa-lib
      glib
      nss
      nspr
      atk
      cups
      dbus
      gtk3
      libdrm
      pango
      cairo
      mesa
      expat
      libxkbcommon
    ]) ++ (with pkgs.xorg; [
      libX11
      libXcursor
      libXrandr
      libXcomposite
      libXdamage
      libXext
      libXfixes
      libxcb
    ]);
    runScript = ''
      Typora $*
    '';
  };

in stdenv.mkDerivation {
  inherit pname version fuck_src;

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  
  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    echo build2
    unzip -q $fuck_src
    mv resources-master/gan-key typora-gen
    chmod a+x typora-gen
    mv typora-gen $out/bin/typora-gen
    echo typora-gen
    ln -s ${typoraFHS}/bin/typora-fhs $out/bin/typora
    ln -s ${typoraBase}/share/ $out
    runHook postInstall
  '';

  meta = with lib; {
    description = "A markdown editor, a markdown reader";
    homepage = "https://typora.io/";
#    license = licenses.unfree;
    maintainers = with maintainers; [ npulidomateo ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "typora";
  };
}
