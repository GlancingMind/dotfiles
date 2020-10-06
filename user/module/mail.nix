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
  #TODO Make solution generic, to generate config for each mail in domain.
  # - so hierarchy need to resemble:
  #     domain/mail-local-part -> if content of domain/ is a file
  #     domain/username/mail-local-part -> if content of domain is dir
  # - Add hash for each set, improves error diagnosis on changed directories
  #     or filenames => but hashes can be "decrypted"
  # - create strict mapping => all keys must have at least one file or error
  # - Must strip filesuffix (use regex groups to add stripping of suffix)
  # - For some key, there must not exist a corresponding file. Could also just
  #     give the value. E.g. Port = "537"; //It could match a file, resulting
  #     in the string 537 or the file does not exists and the string is still
  #     "537". The Regex, ist either the evaluated nix-expression or the
  #     literal value. NOTE: "*.gpg" might not evaluate to a file, the value
  #     "*.gpg" might then be wrong. Should add a function like match "regex"
  #     or use "value";
  # Use import e.g. on
  # accounts.email.accounts = import ./test.nix {
  #   path = "pw-store/personal/emails";
  #   template= {
  #     domain: {
  #       local-part: "regular"; //local part matches a list of regular files
  #       username: {
  #         aliases: "*"; // matches dir, regular, link,...
  #       }; //username is a set == a directory
  #     };
  #   };
  # };
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
