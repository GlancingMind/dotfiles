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


{pkgs ? import <nixpkgs> {}}: with pkgs.lib;
let
  # files read by readDir
  files = [ "sascha.sanjuan.gpg" "faux.dev.gpg" "hello.world" ];
  # template
  email = { hello = 993; local-part = "(.*)\\.gpg$"; };

  isEmpty = list: builtins.length list == 0;

  MatchFiles = regex: files:
    builtins.concatLists
      (builtins.filter
        (value: value != null)
        (map (file: builtins.match (toString regex) file) files)
      );

  # Evaluates to the given subject if the condition is true, otherwise a
  # default value is returned.
  get = {predicate ? null, subject ? null, default ? null}:
    if predicate subject then default else subject;

  set = pkgs.lib.mapAttrsRecursive (path: value:
    get {
      predicate=isEmpty;
      subject=(MatchFiles value files);
      default=value;}
    ) email;
in
  #TODO
  # - refactor names for readabity
  # - implement recursive resolve of nested sets
  set


#let
#  expand = {path, template}: let
#    dirs = builtins.readDir path;
#    files = builtins.attrNames dirs;
#    keys = builtins.attrNames template;
#    ValueForKey = key: template: builtins.getAttr key template;
#    FilterFiles = regex: files:
#      builtins.filter (file: !builtins.isNull(builtins.match regex file)) files;
#    forEachKey = map (key: FilterFiles (ValueForKey key template) files) keys;
#  in
#    forEachKey;
#in {
#  test = expand {
#    path = /. + "/home/sascha/.local/share/password-store/personal/email/";
#    template = {
#      local-parts = ".*\\.de$";
#    };
#  };
#}



#{path, domain}: let
#  filenames = builtins.attrNames (builtins.readDir (path+("/"+domain)));
#  stripFileSuffix = suffix: file: builtins.head (builtins.split suffix file);
#  local-parts = map (mail: (stripFileSuffix "\\.gpg$" mail)) filenames;
#in
#  local-parts

#TODO
# - Get all file of directory or + all subdirectories (rec)
# - Match paths against groups => Convert paths to set
# OR Write a set with names and match filepaths e.g. every key in the set is a
# path resolving function or a key with another set.

#TODO Must read path endings of last directory and filename. E.g. Tread a path
#as list and take last elements. (use stringsplit on slash)

#{path}: let
#  resolve = path: let
#    dirs = builtins.readDir path;
#    names = builtins.attrNames dirs;
#    types = builtins.attrValues dirs;
#    expandPath = name: path + ("/" + name);
#
#    files = builtins.filter (name: builtins.getAttr name dirs != "directory") names;
#    directories = builtins.filter (name: builtins.getAttr name dirs == "directory") names;
#    pathingFiles = files; #map expandPath files;
#    pathingDirs = map (dir: resolve (expandPath dir)) directories;
#  in
#    # keep all files by concatenating files with empty list (flattend
#    # pathingDirs structure [[][]] => [])
#    pathingFiles ++ (builtins.concatLists pathingDirs);
#in
#  resolve path
