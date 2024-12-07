# my-package.nix
{ lib, stdenv, fetchgit, ... }:

stdenv.mkDerivation rec {
  pname = "my-package";
  version = "1.0";

  src = fetchgit {
    url = "https://github.com/moovweb/gvm.git";
    rev = "master";
    # sha256 = lib.fakeSha256;
  };

  installPhase = ''
    mkdir -p $out/gvm
    cp ${src} $out/gvm
  '';

  meta = with lib; {
    description = "A sample package that clones a Git repository";
    license = licenses.mit;
    maintainers = with maintainers; [ maintainers.yourname ];
  };
}

