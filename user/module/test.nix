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






{path, domain}: let
  filenames = builtins.attrNames (builtins.readDir (path+("/"+domain)));
  stripFileSuffix = suffix: file: builtins.head (builtins.split suffix file);
  local-parts = map (mail: (stripFileSuffix "\\.gpg$" mail)) filenames;
in
  local-parts

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
