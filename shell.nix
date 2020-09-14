let
  sources = import ./nix/sources.nix;
  nixpkgs = sources.nixpkgs;
  pkgs = import nixpkgs {};
in pkgs.stdenv.mkDerivation {

  name = "home-manager-shell";

  buildInputs = [
    pkgs.niv
    (import sources.home-manager {inherit pkgs;}).home-manager
    pkgs.nixops
    pkgs.gnumake
  ];

  shellHocks = ''
    export NIX_PATH="nixpkgs=${nixpkgs}";
  '';
}
