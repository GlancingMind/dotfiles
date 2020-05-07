{ pkgs, ... }:
{
  home.packages = with pkgs; [
    pinentry #needed for gpg
  ];

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 300;
    maxCacheTtl = 600;
  };

  programs.password-store = {
    enable = true;
    package = pkgs.pass-wayland.withExtensions (exts: [
      exts.pass-otp
    ]);
  };
}
