{ config, pkgs, ... }:
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  imports = [
    ./role/wayland/sway.nix
    #./role/x11/i3.nix
    ./module/editor/vim/setup.nix
    ./module/shell/zsh/zsh.nix
    ./module/terminal/alacritty/settings.nix
    ./module/password-manager/pass/password-store.nix
  ];

  xdg = {
    enable = true;
    userDirs.enable = true;
    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "x-scheme-handler/about" = "firefox.desktop";
        "x-scheme-handler/unknown" = "firefox.desktop";
      };
    };
  };

  home.packages = with pkgs; [
    zathura htop unzip dash
    xdg_utils
    #gitAndTools.git-bug
    libvirt pkgs.vagrant docker-compose
    vis dvtm abduco #as Vim and Tmux alternative
    vscodium
    chromium
  ];

#  programs.git.enable = true;
#  programs.git.package = pkgs.gitAndTools.gitFull;

  # See all available envs here: https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap08.html
  #   - Setting of Browser and TERM is done by the respective "desktop" environment as wayland requires diffrent browser/terminal as x11
  # NOTE Maybe use:
  # - import or list package directly as dependency e.g. EDITOR = (import .../vim.nix)/bin/vim;
  # - mimeApps.defaultApplications."text/plain" = (import .../vim.nix);
  home.sessionVariables = rec {
    SHELL = "zsh";
    VISUAL = "vim";
    EDITOR = VISUAL;
      # use NIX recursive set as $VISUAL will be empty
      # because home-manager sorts variables and EDITOR
      # will be set before VISUAL is known.
  };
}
