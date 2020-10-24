{ pkgs, ...}:
{
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."sascha" = {
    isNormalUser = true;
    extraGroups = [ "video" "wheel" "docker" "libvirtd" ];
    shell = pkgs.zsh;
  };
}
