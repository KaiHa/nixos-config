{ stdenv
, fetchFromGitHub
, perl
, perlPackages }:

stdenv.mkDerivation rec {
  pname = "xmltoman";
  version = "0.6";

  outputs = [ "out" ];

  src = fetchFromGitHub {
    owner = "atsb";
    repo = "xmltoman";
    rev = version;
    sha256 = "1f4l34xnjyk86l66fpfsy03mdpvrbl9fragss3cc84c1hwc5sq8j";
  };

  nativeBuildInputs = [ ];

  propagatedBuildInputs = [
    perl
    perlPackages.XMLParser
  ];

  doCheck = true;

  postPatch = ''
    substituteInPlace ./xmltoman --replace "#!/usr/bin/perl" "#!${perl}/bin/perl"
    substituteInPlace ./Makefile --replace "\$(prefix)" "$out"
    '';

  meta = with stdenv.lib; {
    description = "xmltoman - scripts to convert xml to man pages in groff format or html";
    homepage = https://github.com/atsb/xmltoman;
    license = licenses.gpl2;
    platforms = platforms.linux;
    maintainers = with maintainers; [ kaiha ];
  };
}
