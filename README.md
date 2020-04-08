# This is work in progress and currently not tested!

# Notes for me

1. Connect to network via:

   $ wpa_passphrase 'SSID' 'KEY' > passphrase.txt
   $ wpa_supplicant -B -i <interface> -c passphrase.txt # Interface could be wlp3s0

1. Generate default hardware-/configuration.nix and add to configuration.nix

  networking.firewall.allowedTCPPorts = [ 22 ];
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";

2.

  link user directory to .config/nixpkgs (take care to use an absolute path as destination!)

