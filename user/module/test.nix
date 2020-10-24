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

#TODO
# - Some regex expressions should not be evaluated by this script
# - implement recursive resolve of nested sets
# -- use filterAttrs to remove all none directories.
{pkgs ? import <nixpkgs> {}}:
let
  # files read by readDir
  EvaluateTemplate = {path, patterns, template}: let

    recReadDir = path: let
      fileset = builtins.readDir path;
      dirset = pkgs.lib.attrsets.filterAttrs (n: v: v == "directory") fileset;
      tree = builtins.mapAttrs (name: type: recReadDir (path+"/"+name)) dirset;
    in fileset // tree;

    joinToPath = pathComponents: builtins.concatStringsSep "/" pathComponents;

    filesetToPaths = set: let
      listPathsInSet = pkgs.lib.attrsets.mapAttrsRecursive (n: v: n) set;
      listPaths = pkgs.lib.attrsets.collect builtins.isList listPathsInSet;
    in
      map joinToPath listPaths;

    fill = path: let
      matchPattern = pattern: map (path: builtins.match pattern path) pathList;
      filterNull = list: (builtins.filter (item: !builtins.isNull item) list);

      fileset = recReadDir path;
      pathList = filesetToPaths fileset;

      matchingPaths = builtins.mapAttrs (name: pattern: matchPattern pattern) patterns;
      nonNull = builtins.mapAttrs (n: list: filterNull list) matchingPaths;
      paths = builtins.mapAttrs (n: v: builtins.concatLists v) nonNull;
    in
      builtins.mapAttrs (n: v: pkgs.lib.lists.unique v) paths;
  in
    fill path;
in
  {
    outlook=EvaluateTemplate {
      path="/home/sascha/nix-config/user/module/test-store/email/outlook.com";
      patterns = let
        username = "(.*)/.*";
        address = "(.*)/(.*)\\.gpg$";
        # TODO with current patterns, could remove redundancy with
        # lists.intersectLists or merge both lists
        # TODO concatenation of username and address seem not to work easily
        # want that for address username
      in {
        inherit username;
        inherit address;
      };
      template={
        #NOTE use username as account name instead of domain name
        username = "TO BE FILLED IN";
        address="TO BE FILLED IN";
        port = 993;
        name = "Poh";
      };
    };
  }

#NOTE
# builtins.dirOf "(.*)" => ".";
# builtins.dirOf "hello/(.*)" => "hello";
# builtins.dirOf "/hello/(.*)" => "/hello";
# Could use it to map regex to dirctory!
