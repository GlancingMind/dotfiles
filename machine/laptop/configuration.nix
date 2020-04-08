# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:
{
  imports = [
    ../role/systemd-networkd.nix
    ../role/sound.nix
    ../role/virtualization.nix
  ];

  networking.firewall.allowedTCPPorts = [ 22 ];
  services.openssh.enable = true;

  # required for zsh completion
  environment.pathsToLink = [ "/share/zsh" ];
  # required to start sway
  hardware.opengl.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.editor = false;

  fonts.enableDefaultFonts = true;

  # Select internationalisation properties.
  #i18n = {
  #  consoleFont = "Lat2-Terminus16";
  #  consoleKeyMap = "de";
  #  defaultLocale = "de_DE.UTF-8";
  #};
  console.font = "Lat2-Terminus16";
  console.keyMap = "de";

  # Set your time zone.
  time.timeZone = "Europe/Berlin";


  # Enable CUPS to print documents.
  services.printing.enable = true;

  hardware.cpu.intel.updateMicrocode = true;

  services.fstrim.enable = true;

  let
    home-manager = builtins.fetchGit {
      url = "https://github.com/rycee/home-manager.git";
      ref = system.stateVersion;
    };
    username = "sascha";
  in
  {
    import = [(import "${home-manager}/nixos")];
    home-manager.users."${username}" = import ../../../user/home.nix

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users."${username}" = {
      isNormalUser = true;
      extraGroups = [ "video" "wheel" "docker" "libvirtd" ];
      shell = pkgs.zsh;
    };
  }


  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?
}
