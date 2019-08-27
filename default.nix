{ mkDerivation, base, stdenv, stm }:
mkDerivation {
  pname = "stm-skip-chan";
  version = "0.1.0.0";
  src = ./.;
  libraryHaskellDepends = [ base stm ];
  homepage = "https://github.com/rehno-lindeque/stm-skip-chan";
  description = "STM based skip chan with combined read";
  license = stdenv.lib.licenses.bsd3;
}
