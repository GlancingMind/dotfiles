{ pkgs, ... }:
{
  programs.zsh = {
    enable = true;
    defaultKeymap = "viins";
    # grml zsh overrides viins setting, need to apply it again after sourcing gmrl
    initExtraBeforeCompInit = "source ${pkgs.grml-zsh-config}/etc/zsh/zshrc\nbindkey -v";
    dotDir = ".config/zsh";
    enableCompletion = true;
  };
}
