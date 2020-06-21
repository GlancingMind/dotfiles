let
  pkgs = import ./nix;
in
pkgs.mkShell {
  buildInputs = [
    pkgs.niv
    pkgs.home-manager
    pkgs.nixops
    pkgs.gnumake
  ];
}
