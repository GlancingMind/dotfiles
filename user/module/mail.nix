{ config, pkgs, lib, ... }:
with lib;
let
  pass = (import ../../nix-plugins).pass;

  inStorePath = account: "personal/email/${account}";

  schema = {
    email = "email: +(.*)";
    login = "login: +(.*)";
  };

  #NOTE home-manager uses the following command as command for "bash -c".
  # That's the reason, why $2 is escaped with a '\\', otherwise "bash -c"
  # will interpret it as an argument reference. As this reference isn't
  # initilized, awk's command will evaluate to {print }. Leading into printing
  # of the whole piped line instead of the specified coloumn and hence a wrong
  # password.
  mailAppPasswordOf = account:
    "pass show ${inStorePath account} | awk '/app-password:/ {print \\$2}'";

  expandConfig = domain: config: let
    accs = builtins.filter (hasSuffix domain) (pass.files "personal/email");
    configs = map (acc: attrsets.nameValuePair acc (config acc)) accs;
  in builtins.listToAttrs configs;

  webDeAccounts = let
    config = account: rec {
      primary = "92747cf9026d18d1d133fcde0b64a2904c1ec1f0" == builtins.hashString "sha1" address;
      address = pass.decrypt.lookupFirst schema.email (inStorePath account);
      userName = pass.decrypt.lookupFirst schema.login (inStorePath account);
      realName = "";
      passwordCommand= "pass show ${inStorePath account}";

      folders = {
        inbox = "INBOX";
        sent = "Gesendet";
        drafts = "Entwurf";
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

      smtp = {
        host = "smtp.web.de";
        port = 587;
        tls.enable = true;
        tls.useStartTls = true;
      };

      mbsync = {
        enable = true;
        create = "maildir";
      };
      msmtp.enable = true;
      notmuch.enable = true;
    };
  in expandConfig "@web.de" config;

  outlookAccounts = let
    config = account: rec {
      address = pass.decrypt.lookupFirst schema.email (inStorePath account);
      userName = address;
      passwordCommand= mailAppPasswordOf account;

      folders = {
        inbox = "INBOX";
        sent = "Sent";
        drafts = "Drafts";
        trash = "Deleted";
      };

      imap = {
        host = "outlook.office365.com";
        port = 993;
        tls = {
          enable = true;
          useStartTls = false;
        };
      };

      smtp = {
        host = "smtp.office365.com";
        port = 587;
        tls.enable = true;
        tls.useStartTls = true;
      };

      mbsync = {
        enable = true;
        create = "maildir";
      };
      msmtp.enable = true;
      notmuch.enable = true;
    };
  in expandConfig "@outlook.com" config;

  yahooAccounts = let
    config = account: rec {
      address = pass.decrypt.lookupFirst schema.email (inStorePath account);
      userName = address;
      realName = "";
      passwordCommand= mailAppPasswordOf account;

      folders = {
        inbox = "INBOX";
        sent = "Sent";
        drafts = "Draft";
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

      smtp = {
        host = "smtp.mail.yahoo.com";
        port = 587;
        tls.enable = true;
        tls.useStartTls = true;
      };

      mbsync = {
        enable = true;
        create = "maildir";
      };
      msmtp.enable = true;
      notmuch.enable = true;
    };
  in expandConfig "@yahoo.de" config;

  thAccounts = let
    config = account: rec {
      address = pass.decrypt.lookupFirst schema.email (inStorePath account);
      userName = pass.decrypt.lookupFirst schema.login (inStorePath account);
      realName = "";
      passwordCommand= "pass show ${inStorePath account}";

      folders = {
        inbox = "INBOX";
        sent = "INBOX/Sent";
        drafts = "INBOX/Drafts";
        trash = "INBOX/Trash";
      };

      imap = {
        host = "mailgate.thm.de";
        port = 993;
        tls = {
          enable = true;
          useStartTls = false;
        };
      };

      smtp = {
        host = "mailgate.thm.de";
        port = 587;
        tls.enable = true;
        tls.useStartTls = true;
      };

      mbsync = {
        enable = true;
        create = "maildir";
      };
      msmtp.enable = true;
      notmuch.enable = true;
    };
  in expandConfig "@mni.thm.de" config;
in
{
  programs.mbsync.enable = true;
  programs.msmtp.enable = true;
  programs.notmuch.enable = true;

  accounts.email.accounts = webDeAccounts // yahooAccounts
    // outlookAccounts // thAccounts;
}
