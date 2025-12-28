{
  stdenv,
  lib,
  fetchzip,
  makeWrapper,
  autoPatchelfHook,

  zlib,
  openssl,
  ncurses,
  lz4,
  libtiff,
  fontconfig,
  cairo,
  pango,
  glib,
  libjpeg_turbo,
}:

stdenv.mkDerivation {
  pname = "breezewiki";
  version = "2025-11-28";

  src = fetchzip {
    url = "https://web.archive.org/web/20251228120825/https://docs.breezewiki.com/files/breezewiki-dist.tar.gz";
    hash = "sha256-RyG10ASLx54EPyJhbvweJpW65vx0oTBHipEWotdmxGc=";
  };

  nativeBuildInputs = [
    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = [
    zlib
    openssl
    ncurses
    lz4
    libtiff
  ];

  installPhase = ''
    mkdir -p $out/dist
    cp -r {bin,lib} $out/dist

    mkdir -p $out/bin
    makeWrapper $out/dist/bin/dist $out/bin/breezewiki \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          fontconfig
          cairo
          pango
          glib
          libjpeg_turbo
          openssl
        ]
      }"
  '';

  meta = with lib; {
    description = "Alternative frontend for Fandom";
    homepage = "https://gitdab.com/cadence/breezewiki";
    mainProgram = "breezewiki";
    license = licenses.agpl3Only;
    platforms = platforms.linux;
  };
}
