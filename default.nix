{ stdenv, lib, makeWrapper,
  bash, coreutils, gnugrep, gawk, findutils, fzf, ffmpeg-full
}:

stdenv.mkDerivation {
  pname = "gipher";
  version = "0.1.0";
  src = ./gipher.sh;

  nativeBuildInputs = [
    makeWrapper
  ];

  unpackPhase = "true";

  installPhase = let
    deps = [
      fzf
      ffmpeg-full
      bash
      coreutils
      gnugrep
      gawk
      findutils
    ];
  in ''
    makeWrapper $src $out/bin/gipher \
      --set PATH "${lib.makeBinPath deps}"
  '';
}
