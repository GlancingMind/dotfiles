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
    qt5.qtwayland
    source-code-pro
  ];

  fonts.fontconfig.enable = true;

  programs.firefox = lib.attrsets.recursiveUpdate (import ../../program/browser/web/firefox/firefox.nix) {
    package = pkgs.firefox-wayland;
  };

  xdg.configFile."i3status".source = ../../program/status/i3status;

  wayland.windowManager.sway = {
    enable = true;
    xwayland = false;
    extraSessionCommands = ''#
      export TERM=alacritty
      export BROWSER=firefox
      #
      # enable wayland support for firefox
        export MOZ_ENABLE_WAYLAND=1
      #
      # needs qt5.qtwayland in systemPackages
        export QT_QPA_PLATFORM=wayland
        export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      export _JAVA_OPTIONS=-Dawt.useSystemAAFontSettings=lcd_hrgb
      export _JAVA_AWT_WM_NONREPARENTING=1'';
    config = {
      modifier = "Mod4";
      terminal = "${pkgs.alacritty}/bin/alacritty";
      menu = "BEMENU_BACKEND=wayland ${pkgs.bemenu}/bin/bemenu-run -i";
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
      output = {
        "*" = {
          bg = "${glenda-wallpaper} fit #ffffff";
        };
        VGA-1 = {
          resolution = "1600x900";
          position = "0,0";
        };
        LVDS-1 = {
          resolution = "1366x768";
          position = "0,900";
        };
      };
      bars = [
        {
          position = "top";
          statusCommand = "${pkgs.i3status}/bin/i3status";
          fonts = [ "Monospace 9" "SourceCodePro 9" ];
        }
      ];
    };
  };
}
