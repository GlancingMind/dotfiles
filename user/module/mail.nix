{ config, pkgs, lib, ... }:
let
  pws-dir = "${config.programs.password-store.settings.PASSWORD_STORE_DIR}";
  pass = (import ../../nix-plugins).nix-plugins.pass;
  schema = {
    email = "email: +(.*)";
    login = "login: +(.*)";
  };
in
{
  programs.mbsync.enable = true;

  accounts.email.accounts = {
    web = let
      passwordPath = "/personal/email/web.de/sascha.sanjuan";
      path = pws-dir + passwordPath;
      addresses = pass.decrypt.lookup schema.email passwordPath;
    in {
        primary = true;
        address = builtins.head addresses;
        userName = builtins.head addresses;
        passwordCommand = "pass ${path} | head -n 1";

        imap = {
          host = "imap.web.de";
          port = 993;
          tls = {
            enable = true;
            useStartTls = false;
          };
        };

        mbsync = {
          enable = true;
        #  create = "both";
        #  groups = {
        #    "web".channels = {
        #      "web-default" = {
        #        masterPattern = "web-remote";
        #        slavePattern = "web-local";
        #        patterns = "* !INBOX !Posteingang";
        #      };
        #      "web-inbox" = {
        #        masterPattern = "INBOX";
        #        slavePattern = "Posteingang";
        #      };
        #    };
        #  };
        };
      };
  };
}
