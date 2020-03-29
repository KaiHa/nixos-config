{ stdenv
, pkgs
, fetchFromGitHub
, meson
, ninja
, pkgconfig
, doxygen
, graphviz
, valgrind
, glib
, dbus
, gst_all_1
, alsaLib
, ffmpeg
, libjack2
, udev
, libva
, xorg
, sbc
, SDL2
, makeFontsConf
, bluez
, libpulseaudio
, libsndfile
, vulkan-headers
, vulkan-loader
}:

let
  fontsConf = makeFontsConf {
    fontDirectories = [];
  };
  xmltoman = pkgs.callPackage ./xmltoman.nix {};
in
stdenv.mkDerivation rec {
  pname = "pipewire";
  version = "0.3.2";

  outputs = [ "out" "lib" "dev" ];

  src = fetchFromGitHub {
    owner = "PipeWire";
    repo = "pipewire";
    rev = version;
    sha256 = "1aqhaaranv1jlc5py87mzfansxhzzpawqrfs8i08qc5ggnz6mfak";
  };

  nativeBuildInputs = [
    doxygen
    graphviz
    meson
    ninja
    pkgconfig
    valgrind
    xmltoman
  ];

  buildInputs = [
    SDL2
    alsaLib
    bluez
    dbus
    ffmpeg
    glib
    gst_all_1.gst-plugins-base
    gst_all_1.gstreamer
    libjack2
    libpulseaudio
    libsndfile
    libva
    sbc
    udev
    vulkan-headers
    vulkan-loader
    xorg.libX11
  ];

  mesonFlags = [ ];

  PKG_CONFIG_SYSTEMD_SYSTEMDUSERUNITDIR = "${placeholder "out"}/lib/systemd/user";

  FONTCONFIG_FILE = fontsConf; # Fontconfig error: Cannot load default config file

  doCheck = true;

  patches = [ ./service-file.patch ];

  postPatch = ''
    substituteInPlace src/daemon/systemd/user/pipewire.service.in --subst-var-by PW_PATH $out/bin
    '';

  meta = with stdenv.lib; {
    description = "Server and user space API to deal with multimedia pipelines";
    homepage = https://pipewire.org/;
    license = licenses.lgpl21;
    platforms = platforms.linux;
    maintainers = with maintainers; [ jtojnar ];
  };
}
