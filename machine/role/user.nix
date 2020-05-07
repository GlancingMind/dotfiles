{ pkgs, ...}:
let
#  home-manager = builtins.fetchGit {
#    url = "https://github.com/rycee/home-manager.git";
#    ref = "release-19.09";
#  };
in
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."sascha" = {
    isNormalUser = true;
    extraGroups = [ "video" "wheel" "docker" "libvirtd" ];
    shell = pkgs.zsh;
  };
}
