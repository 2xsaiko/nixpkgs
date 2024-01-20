{ stdenv
, fetchgit
, lib
, pkgconf
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "liba2i";
  version = "unstable-2024-01-13";

  src = fetchgit {
    url = "git://www.alejandro-colomar.es/src/alx/alx/liba2i.git";
    rev = "1d54d788038e671a5f85d79dd932b322247f03e2";
    hash = "sha256-HqcQq8I91IYzBsFXoMdiivfc5iBCQcM/QmSw/jbuNhM=";
  };

  postPatch = ''
    substituteInPlace GNUmakefile \
      --replace 'SHELL := /usr/bin/env' "" \
      --replace '.SHELLFLAGS := -S bash -Eeuo pipefail -c' ""
    substituteInPlace share/mk/build-deps.mk \
      --replace 'DEFAULT_CFLAGS += -Werror' ""
  '';

  makeFlags = [
    "prefix=${placeholder "out"}"
    "V=1"
  ];

  nativeBuildInputs = [
    pkgconf
  ];

  outputs = [ "out" "dev" ];

  # Overriding EXTRA_CFLAGS doesn't change anything, so I had to use this.
  env.NIX_CFLAGS_COMPILE = "-O3";

  meta = {
    description = "Library to parse numbers from strings";
    homepage = "https://www.alejandro-colomar.es/src/alx/alx/liba2i.git/";
    license = lib.licenses.lgpl3Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ drupol ];
  };
})
