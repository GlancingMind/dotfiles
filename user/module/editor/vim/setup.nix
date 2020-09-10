{ config, pkgs, stdenv, ... }:

let
  minpac = pkgs.vimUtils.buildVimPlugin {
    name = "minpac";
    src = builtins.fetchGit {
      url = "https://github.com/k-takata/minpac.git";
      ref = "master";
    };
  };
in
{
  home.packages = [
  ];

  # required for vim-minpac
  programs.git.enable = true;
  programs.git.package = pkgs.gitMinimal;

  xdg.configFile."vim" = {
    source = ./config;
    recursive = true;
  };

  home.sessionVariables = {
    VIMINIT = ":source ${config.xdg.configHome}/vim/vimrc";
  };

  programs.vim.enable = true;
  programs.vim.plugins = [
    minpac
  ];
  programs.vim.extraConfig = ''source ${config.xdg.configHome}/vim/vimrc'';
}
