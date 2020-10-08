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
#{path, template}: let
#
#in


{pkgs ? import <nixpkgs> {}}:
let
  # files read by readDir
  emailfiles = [ "sascha.sanjuan.gpg" "faux.dev.gpg" "hello.world" ];
  # template
  email = { hello = 993; local-part = "(.*)\\.gpg$"; };

  MatchFilename = regex: filename:
    builtins.match (toString regex) filename;

  MatchFiles = regex: files:
    builtins.concatLists
      (pkgs.lib.lists.remove null
        (pkgs.lib.forEach files (MatchFilename regex))
      );

  MatchFilesOrDefault = {regex, files, default}: let
    matches = MatchFiles regex files;
    noMatches = (matches == []);
  in
    if noMatches then default else matches;

  EvaluateTemplate = pkgs.lib.mapAttrsRecursive
    (path: value: MatchFilesOrDefault {
      regex=value;
      files=emailfiles;
      default=value;})
    email;
in
  #TODO
  # - Some regex expressions should not be evaluated by this script
  # - implement recursive resolve of nested sets
  # -- use filterAttrs to remove all none directories.
  EvaluateTemplate
