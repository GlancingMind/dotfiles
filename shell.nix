let
  sources = import ./nix/sources.nix;
  nixpkgs = sources.nixpkgs;
  pkgs = import nixpkgs {};
in pkgs.stdenv.mkDerivation {

  name = "home-manager-shell";

  buildInputs = [
    pkgs.niv
    (import sources.home-manager {inherit pkgs;}).home-manager
    pkgs.gnumake
  ];

  shellHooks = ''
    export NIX_PATH="nixpkgs=${nixpkgs}";
  '';
}
