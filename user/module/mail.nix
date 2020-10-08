#TODO seems to be no longer required => maybe delete
# pws-dir = /. + "${config.programs.password-store.settings.PASSWORD_STORE_DIR}";
#  # Using ESH templates see here:
#  # https://github.com/jirutka/esh/blob/master/esh.1.adoc#L2
#  template = ''
#      { web="<% ${pkgs.gnupg}/bin/gpg2 -q --for-your-eyes-only --no-tty -d ${pws-dir}/personal/kobo.com  %>";  }
#    '';
#  filled-template = pkgs.runCommand "fill-template" {} ''
#      echo ${lib.escapeShellArg template} | ${pkgs.esh}/bin/esh - >> $out
#    '';
#  result-template = import filled-template;
{ config, pkgs, lib, ... }:
let
  pws-dir = "${config.programs.password-store.settings.PASSWORD_STORE_DIR}";
in
{
  programs.mbsync.enable = true;

  accounts.email.accounts = {
    web = let
        domain = "web.de";
        local-parts = import ./test.nix {
          path="${pws-dir}/personal/email";
          domain=domain;
        };
        local-part = builtins.head local-parts;
      in rec {
        primary = true;
        address = builtins.concatStringsSep "@" [ local-part domain ];
        userName = address;
        passwordCommand = "pass personal/email/${domain}/${local-part} | head -n 1";

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
