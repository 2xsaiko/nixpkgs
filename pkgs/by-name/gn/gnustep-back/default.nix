{ lib
, clangStdenv
, gnustep-make
, wrapGNUstepAppsHook
, cairo
, fetchzip
, gnustep-base
, gnustep-gui
, fontconfig
, freetype
, pkg-config
, libXft
, libXmu
}:

clangStdenv.mkDerivation (self: {
  pname = "gnustep-back";
  version = "0.30.0";

  src = fetchzip {
    url = "ftp://ftp.gnustep.org/pub/gnustep/core/${self.pname}-${self.version}.tar.gz";
    sha256 = "sha256-HD4PLdkE573nPWqFwffUmcHw8VYIl5rLiPKWrbnwpCI=";
  };

  nativeBuildInputs = [ gnustep-make pkg-config wrapGNUstepAppsHook ];
  buildInputs = [ cairo gnustep-base gnustep-gui fontconfig freetype libXft libXmu ];

  meta = {
    description = "A generic backend for GNUstep";
    homepage = "http://gnustep.org/";
    license = lib.licenses.lgpl2Plus;
    maintainers = with lib.maintainers; [ ashalkhakov matthewbauer dblsaiko ];
    platforms = lib.platforms.linux;
  };
})
