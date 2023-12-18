{ lib
, stdenv
, fetchzip
, base
, back
, make
, wrapGNUstepAppsHook
, gui
}:

stdenv.mkDerivation (self: {
  pname = "gorm";
  version = "1.3.1";

  src = fetchzip {
    url = "ftp://ftp.gnustep.org/pub/gnustep/dev-apps/gorm-${self.version}.tar.gz";
    sha256 = "sha256-W+NgbvLjt1PpDiauhzWFaU1/CUhmDACQz+GoyRUyWB8=";
  };

  nativeBuildInputs = [ make wrapGNUstepAppsHook ];
  buildInputs = [ base back gui ];

  meta = {
    description = "Graphical Object Relationship Modeller is an easy-to-use interface designer for GNUstep";
    homepage = "http://gnustep.org/";
    license = lib.licenses.lgpl2Plus;
    mainProgram = "Gorm";
    maintainers = with lib.maintainers; [ ashalkhakov matthewbauer dblsaiko ];
    platforms = lib.platforms.linux;
  };
})
