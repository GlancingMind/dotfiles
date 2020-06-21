let
  sources = import ./sources.nix;
  overlay = self: super: {
    niv = (import sources.niv {}).niv;
    home-manager = (import sources.home-manager {}).home-manager;
  };
in
  import sources.nixpkgs {
    overlays = [ overlay ];
    config = {};
  }
