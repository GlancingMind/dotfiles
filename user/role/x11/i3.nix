{ config, lib, pkgs, ...}:
let
  glenda-wallpaper = builtins.fetchurl {
    url = https://9p.io/plan9/img/spaceglenda300.jpg;
    sha256 = "1d16z1ralcvif6clyn244w08wypbvag1hrwi68jbdpv24x0r2vfg";
  };
in
{
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    siji terminus_font_ttf
  ];

  programs.chromium = {
    enable = true;
    extensions = [
      "cjpalhdlnbpafiamejdnhcphjbkeiagm" #ublock origin
      "pkehgijcmpdhfbdbbnkijodmdjhbjlgp" #privacy badger
      "omkfmpieigblcllmkgbflkikinpkodlk" #enhanced-h264ify
    ];
  };

  xsession = {
    enable = true;
    initExtra = ''
      setxkbmap -model pc105 -layout de -variant nodeadkeys
      ${pkgs.feh}/bin/feh --bg-scale --no-fehbg ${glenda-wallpaper}
      export TERM=alacritty;
      export BROWSER=firefox

      export _JAVA_OPTIONS=-Dawt.useSystemAAFontSettings=lcd_hrgb
      export _JAVA_AWT_WM_NONREPARENTING=1
    '';
  };

#  xsession.windowManager.command = "${pkgs.i3}/bin/i3";
  xsession.windowManager.i3 = {
    enable = true;
    config = {
      modifier = "Mod4";
      terminal = "${pkgs.alacritty}/bin/alacritty";
      menu = "${pkgs.dmenu}/bin/dmenu_run";
      bars = [
        {
          position = "top";
          command = "${pkgs.i3status}/bin/i3status";
          fonts = [ "siji 8" "Terminus (TTF) 8" ];
        }
      ];
      keybindings = lib.mkOptionDefault {
        "XF86AudioRaiseVolume" = "exec amixer -q sset Master 3%+ unmute";
        "XF86AudioLowerVolume" = "exec amixer -q sset Master 3%- unmute";
        "XF86AudioMute" = "exec amixer -q sset Master toggle";
        "XF86AudioMicMute" = "exec amixer set Capture toggle";
        "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 10%+";
        "XF86MonBrightnessDown" = " exec ${pkgs.brightnessctl}/bin/brightnessctl set 10%-";
      };
    };
  };
}
