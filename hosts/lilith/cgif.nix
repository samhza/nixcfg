{stdenv, fetchFromGitHub, meson, ninja}:
stdenv.mkDerivation {
  name = "cgif";
  src = fetchFromGitHub {
    rev = "V0.3.0";
    owner = "dloebl";
    repo = "cgif";
    sha256 = "sha256-vSEPZEhp1Fpu0SiKWFjP8ESu3BKfKjQYWWeM75t/rEA=";
  };
  nativeBuildInputs = [ meson ninja ];
}