{ config, lib, pkgs, ...}:
{
  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    siji terminus_font_ttf
  ];

  programs.chromium = {
    enable = true;
    extensions = [
      cjpalhdlnbpafiamejdnhcphjbkeiagm #ublock origin
      pkehgijcmpdhfbdbbnkijodmdjhbjlgp #privacy badger
      omkfmpieigblcllmkgbflkikinpkodlk #enhanced-h264ify
    ];
  };

  xsession.windowManager.i3 = {
    enable = true;
    extraSessionCommands = ''
      export TERM=alacritty;
      export BROWSER=firefox

      export _JAVA_OPTIONS=-Dawt.useSystemAAFontSettings=lcd_hrgb
      export _JAVA_AWT_WM_NONREPARENTING=1
    '';
    config = {
      modifier = "Mod4";
      terminal = "${pkgs.alacritty}/bin/alacritty";
      menu = "${pkgs.dmenu}/bin/dmenu_run";
      input = {
        "*" = {
          xkb_layout = "de";
          xkb_model = "pc105";
          xkb_variant = "nodeadkeys";
        };
      };
      keybindings = lib.mkOptionDefault {
        "XF86AudioRaiseVolume" = "exec amixer -q sset Master 3%+ unmute";
        "XF86AudioLowerVolume" = "exec amixer -q sset Master 3%- unmute";
        "XF86AudioMute" = "exec amixer -q sset Master toggle";
        "XF86AudioMicMute" = "exec amixer set Capture toggle";
        "XF86MonBrightnessUp" = "exec ${pkgs.brightnessctl}/bin/brightnessctl set 10%+";
        "XF86MonBrightnessDown" = " exec ${pkgs.brightnessctl}/bin/brightnessctl set 10%-";
      };
      bars = [
        {
          position = "top";
          statusCommand = "${pkgs.i3status}/bin/i3status";
          fonts = [ "siji 8" "Terminus (TTF) 8" ];
        }
      ];
    };
  };
}
