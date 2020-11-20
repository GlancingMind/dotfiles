{ config, pkgs, stdenv, ... }:

let
  trackedPlugins = import ./plugins.nix {};
in
{
  programs.neovim = {
    enable = true;
    extraConfig = builtins.readFile ./config/nvimrc;
    plugins = with trackedPlugins; [
      gruvbox
      {
        plugin = vim-baker;
        config = builtins.readFile ./config/baker.vim;
      }
      vim-erlang-omnicomplete
      vim-erlang-runtime
      vim-fugitive
      vim-surround
      {
        plugin = vimwiki;
        config = builtins.readFile ./config/vimwiki.vim;
      }
      trackedPlugins."literate.vim"
      {
        plugin = hardmode;
        #config = builtins.readFile ./config/hardmode.vim
      }
      vim-editorconfig
      {
        plugin = vim-editorconfig;
        config = builtins.readFile ./config/editorconfig.vim;
      }
      emmet-vim
      Ada-Bundle
      vim-nix
      psc-ide-vim
      purescript-vim
      vim-reason-plus

      {
        plugin = vim-lsp;
        config = builtins.readFile ./config/lsp.vim;
      }
      # required by vim-lsp
      trackedPlugins."asyncomplete.vim"
      # required by vim-lsp
      trackedPlugins."asyncomplete-lsp.vim"
    ];
  };
}
