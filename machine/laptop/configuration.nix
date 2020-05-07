# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, lib, pkgs, ... }:
{
  imports = [
    ../role/systemd-networkd.nix
    ../role/sound.nix
    ../role/virtualization.nix
    ../role/user.nix
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
  console.font = "Lat2-Terminus16";
  console.keyMap = "de";

  # Set your time zone.
  time.timeZone = "Europe/Berlin";


  # Enable CUPS to print documents.
  #services.printing.enable = true;

  hardware.cpu.intel.updateMicrocode = true;

  services.fstrim.enable = true;

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "20.03"; # Did you read the comment?
}
