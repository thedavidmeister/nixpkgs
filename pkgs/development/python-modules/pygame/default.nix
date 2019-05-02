{ lib, fetchPypi, buildPythonPackage, python, pkg-config, libX11
, SDL, SDL_image, SDL_mixer, SDL_ttf, libpng, libjpeg, portmidi, freetype
}:

buildPythonPackage rec {
  pname = "pygame";
  version = "1.9.5";

  src = fetchPypi {
    inherit pname version;
    sha256 = "d15e7238015095a12c19379565a66285e989fdcb3807ec360b27338cd8bdaf05";
  };

  nativeBuildInputs = [
    pkg-config SDL
  ];

  buildInputs = [
    SDL SDL_image SDL_mixer SDL_ttf libpng libjpeg
    portmidi libX11 freetype
  ];

  # Tests fail because of no audio device and display.
  doCheck = false;

  preConfigure = ''
    sed \
      -e "s/^origincdirs = .*/origincdirs = []/" \
      -e "s/^origlibdirs = .*/origlibdirs = []/" \
      -e "/\/include\/smpeg/d" \
      -i config_unix.py
    ${lib.concatMapStrings (dep: ''
      sed \
        -e "/^origincdirs =/aorigincdirs += ['${lib.getDev dep}/include']" \
        -e "/^origlibdirs =/aoriglibdirs += ['${lib.getLib dep}/lib']" \
        -i config_unix.py
      '') buildInputs
    }
    LOCALBASE=/ ${python.interpreter} config.py
  '';

  meta = with lib; {
    description = "Python library for games";
    homepage = http://www.pygame.org/;
    license = licenses.lgpl21Plus;
    platforms = platforms.linux;
  };
}
