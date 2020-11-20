#TODO should track niv and packages individually for vim?
# should make no sense as this is used with home-manager
#TODO require pkgs or require vimUtils?
{
  pkgs ? import <nixpkgs> {}
  #vimUtils
}: let
  sources = import ./nix/sources.nix {};
  buildVimPlugin = pkgs.vimUtils.buildVimPluginFrom2Nix;
in builtins.mapAttrs (n: v: buildVimPlugin {
  name = n;
  pname = n;
  src = builtins.fetchTarball {inherit (v) url sha256;};
}) sources
