{ pkgs,...}:
{
  environment.systemPackages = with pkgs; [
    iwd
  ];

  networking.hostName = "thinkpad";
  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.dhcpcd.enable = false;
  networking.useNetworkd = true;
  services.resolved.enable = true;

  networking.wireless.iwd.enable = true;
  systemd.network.enable = true;
  systemd.network.networks."99-main".enable = false;
  systemd.network.networks."25-wireless" = {
    name = "wlan0";
    DHCP = "yes";
    networkConfig = {
      IPv6PrivacyExtensions = "yes";
    };
  };
  #systemd.network.networks."20-wired" = {
  #  name = "en*";
  #  DHCP = "yes";
  #  networkConfig = {
  #    IPv6PrivacyExtensions = "yes";
  #  };
  #};
}
