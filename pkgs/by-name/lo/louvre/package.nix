{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, meson
, ninja
, pkg-config
, fontconfig
, icu
, libdrm
, libGL
, libinput
, libX11
, libXcursor
, libxkbcommon
, mesa
, pixman
, seatd
, srm-cuarzo
, udev
, wayland
, xorgproto
}:
stdenv.mkDerivation (self: {
  pname = "louvre";
  version = "1.2.1-2";
  rev = "v${self.version}";
  hash = "sha256-jHMgn6EwWt9GMT8JvIUtUPbn9o1DZCzxiYC7RnoGZv0=";

  src = fetchFromGitHub {
    inherit (self) rev hash;
    owner = "CuarzoSoftware";
    repo = "Louvre";
  };

  patches = [
    (fetchpatch {
      url = "https://github.com/CuarzoSoftware/Louvre/commit/9f85092372ee7f16962fe1e5df4a4ea32d7876a0.patch";
      hash = "sha256-9o+rknw+Wd7+QrX/Kx6Q6PU7HgZEk9hRlVWN15X8TDA=";
    })
    (fetchpatch {
      url = "https://github.com/CuarzoSoftware/Louvre/commit/d3d8715ad7914237644a2e4cc89f888a283e17c7.patch";
      hash = "sha256-h2TlPRWRUyOIpTg5a8lAHdR3vGr81NzoRKpVrgJw2d4=";
    })
  ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    fontconfig
    icu
    libdrm
    libGL
    libinput
    libX11
    libXcursor
    libxkbcommon
    mesa
    pixman
    seatd
    srm-cuarzo
    udev
    wayland
    xorgproto
  ];

  outputs = [ "out" "dev" ];

  preConfigure = ''
    # The root meson.build file is in src/
    cd src
  '';

  meta = {
    description = "C++ library for building Wayland compositors";
    homepage = "https://github.com/CuarzoSoftware/Louvre";
    mainProgram = "louvre-views";
    maintainers = [ lib.maintainers.dblsaiko ];
    platforms = lib.platforms.linux;
  };
})
