{ pkgs, ... }:
{
  home.packages = with pkgs; [
    pinentry        #needed for gpg
    pinentry-curses #needed for gpg
    gopass
  ];

  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    defaultCacheTtl = 300;
    maxCacheTtl = 600;
    pinentryFlavor = "curses";
    grabKeyboardAndMouse = true;

    extraConfig = ''
      ignore-cache-for-signing
      no-allow-external-cache
    '';
  };

  programs.password-store = {
    enable = true;
    package = pkgs.pass-wayland.withExtensions (exts: [
      exts.pass-otp
    ]);
  };
}
