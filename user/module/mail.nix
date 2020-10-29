{ config, pkgs, lib, ... }:
let
  pws-dir = "${config.programs.password-store.settings.PASSWORD_STORE_DIR}";
  pass = (import ../../nix-plugins).nix-plugins.pass;
  pass-name = expandedPath:
    lib.strings.removeSuffix ".gpg" (
      lib.strings.removePrefix (pws-dir+"/") expandedPath);
  extractAppPassword = "sed -n 's/^.*app-password:\\s*\\(\\S*\\).*$/\\1/p'";
  template = import ./test.nix {};

  webDeAccounts = builtins.listToAttrs (template.expand {
    path="${pws-dir}/personal/email/web.de";
    do = {expandedPath}: {
      name = pass-name expandedPath;
      value = rec {
        primary = "92747cf9026d18d1d133fcde0b64a2904c1ec1f0" == builtins.hashString "sha1" address;
        address = builtins.head (pass.decrypt.lookup "email: +(.*)" (pass-name expandedPath));
        userName = address;
        passwordCommand="pass show ${pass-name expandedPath}";

        folders = {
          drafts = "Entwurf";
          inbox = "Inbox";
          sent = "Gesendet";
          trash = "Papierkorb";
        };

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
          create = "maildir";
        };
      };
    };
  });

  outlookAccounts = builtins.listToAttrs (template.expand {
    path="${pws-dir}/personal/email/outlook.com";
    do = {expandedPath}: {
      name = pass-name expandedPath;
      value = let
      in rec {
        address = builtins.head (pass.decrypt.lookup "email: +(.*)" (pass-name expandedPath));
        userName = address;
        passwordCommand= "pass show ${pass-name expandedPath} | awk '/app-password:/ {print $2}'";

        folders = {
          drafts = "Drafts";
          inbox = "Inbox";
          sent = "Sent";
          trash = "Deleted"; #
        };

        imap = {
          host = "outlook.office365.com";
          port = 993;
          tls = {
            enable = true;
            useStartTls = false;
          };
        };

        mbsync = {
          enable = true;
          create = "maildir";
        };
      };
    };
  });

  #TODO
  # load mbsync from unstable channel and test in shell, if problem is resolved
  yahooAccounts = builtins.listToAttrs (template.expand {
    path="${pws-dir}/personal/email/yahoo.com";
    do = {expandedPath}: {
      name = pass-name expandedPath;
      value = rec {
        address = builtins.head (pass.decrypt.lookup "email: +(.*)" (pass-name expandedPath));
        userName = address;
        passwordCommand= "pass show ${pass-name expandedPath} | awk '/app-password:/ {print $2}'";

        folders = {
          drafts = "Draft"; #
          inbox = "Inbox";
          sent = "Sent";
          trash = "Trash";
        };

        imap = {
          host = "imap.mail.yahoo.com";
          port = 993;
          tls = {
            enable = true;
            useStartTls = false;
          };
        };

        mbsync = {
          enable = true;
          create = "maildir";
        };
      };
    };
  });

  thMail = builtins.listToAttrs (template.expand {
    path="${pws-dir}/personal/email/mni.thm.de";
    do = {expandedPath}: {
      name = pass-name expandedPath;
      value = rec {
        address = builtins.head (pass.decrypt.lookup "email: +(.*)" (pass-name expandedPath));
        userName = builtins.head (pass.decrypt.lookup "login: +(.*)" (pass-name expandedPath));
        passwordCommand="pass show ${pass-name expandedPath}";

        folders = {
          drafts = "Drafts";#
          inbox = "Inbox";  #
          sent = "Sent";    #
          trash = "Trash";  #
        };

        imap = {
          host = "mailgate.thm.de";
          port = 993;
          tls = {
            enable = true;
            useStartTls = false;
          };
        };

        mbsync = {
          enable = true;
          create = "maildir";
        };
      };
    };
  });
in
{
  programs.mbsync.enable = true;

  accounts.email.accounts = outlookAccounts // yahooAccounts // webDeAccounts // thMail;
}
