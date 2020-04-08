{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    apulse
  ];

  sound.enable = true;
  # when enabled be sure to install apulse too!
  hardware.pulseaudio.enable = true;
}
