{ stdenv
, fetchurl
, electron
, lib
, makeWrapper
, ...
} @ args:

stdenv.mkDerivation rec {
  pname = "bilibili";
  version = "1.13.0.3194";
  src = fetchurl {
    url = "https://github.com/msojocs/bilibili-linux/releases/download/continuous/io.github.msojocs.bilibili_${version}-continuous_amd64.deb";
    sha256 = "sha256-Fs0DgPN6B/SWdY7doYc1vyUIQMHczb48fvv1p9ztDL8=";
  };

  # 解压 DEB 包
  unpackPhase = ''
    ar x ${src}
    tar xf data.tar.xz
  '';

  # makeWrapper 可以自动生成一个调用其它命令的命令（也就是 wrapper），并且可以在原命令上修改参数、环境变量等
  buildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin

    # 替换菜单项目（desktop 文件）中的路径
    cp -r usr/share $out/share
    sed -i "s|Exec=.*|Exec=$out/bin/bilibili|" $out/share/applications/*.desktop

    # 复制出客户端的 Javascript 部分，其它的不要了
    cp -r opt/apps/io.github.msojocs.bilibili/files/bin/app $out/opt

    # 生成 bilibili 命令，运行这个命令时会调用 electron 加载客户端的 Javascript 包（$out/opt/app.asar）
    makeWrapper ${electron}/bin/electron $out/bin/bilibili \
      --argv0 "bilibili" \
      --add-flags "$out/opt/app.asar"
  '';
}
