{ pkgs,...}:
{
  # must add user to libvirtd and docker group
  virtualisation.docker.enable = true;
  virtualisation.libvirtd.enable = true;
  services.qemuGuest.enable = true;
  services.nfs.server.enable = true;


  # Open ports in the firewall.
  networking.firewall =
    let
      vagrant.nfs.ports = [ 111 2049 20048 ];
    in {
      allowedTCPPorts = vagrant.nfs.ports;
      allowedUDPPorts = vagrant.nfs.ports;
    };
}
