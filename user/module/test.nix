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
  #emailfiles = [ "sascha.sanjuan.gpg" "faux.dev.gpg" "hello.world" ];
  stripHead = path: builtins.concatStringsSep "/" (builtins.tail
        (pkgs.lib.strings.splitString "/" path));

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

  #TODO recurse conditianal only when set contains alias!
  #EvaluateTemplate = {path, template}:
  #  pkgs.lib.mapAttrsRecursive
  #    (attrPath: value: MatchFilesOrDefault {
  #      regex=value;
  #      files=emailfiles ("/" + (stripHead path));
  #      default=value;})
  #    template;

#  EvaluateTemplate = {path, template}: let
#    entries = builtins.readDir (./. + path);
#    files = builtins.attrNames (pkgs.lib.attrsets.filterAttrs (n: v: v != "directory") entries);
#    dirs = builtins.attrNames (pkgs.lib.attrsets.filterAttrs (n: v: v == "directory") entries);
#    descend = dir: builtins.concatStringsSep "/" [ path dir ];
#  in
#    if dirs != {} then
#      pkgs.lib.mapAttrsRecursive
#        (attrPath: value: MatchFilesOrDefault {
#          regex=value;
#          files=files;
#          default=value;})
#        template
#    else
#      path;

  EvaluateTemplate = {path, template}: let
    # convert template to large regex!
    depth = builtins.length;

    # Group directories in path in a set called domain
    # Group directories in domainpath in a set called username
    # Group files in domainpath in a set called address

    # TODO: must add files to directories!
    files = path: let
      fileset = builtins.readDir path;
      dirset = pkgs.lib.attrsets.filterAttrs (n: v: v == "directory") fileset;
      tree = builtins.mapAttrs (name: type: files (path+"/"+name)) dirset;
    in fileset // tree;

    #NOTE
    # builtins.dirOf "(.*)" => ".";
    # builtins.dirOf "hello/(.*)" => "hello";
    # builtins.dirOf "/hello/(.*)" => "/hello";
    # Could use it to map regex to dirctory!

    resolveValue = v: MatchFilesOrDefault {
        regex=v;
        files=files;
        default=v;};

    resolve = {name, value}:
        pkgs.lib.attrsets.nameValuePair (resolveValue name) (resolveValue
        value);

    mapping = pkgs.lib.mapAttrsRecursive
      (n: v: resolve {name=n; value=v;})
      rec {username="^(.*)"; aliases="${username}/(.*)\\.gpg$";};
  in
    #mapping;
    files "/home/sascha/nix-config/user/module/test-store";
in
  {
    outlook=EvaluateTemplate {
      path="/test-store/email/outlook.com";
      template={
        user={
          name="(.*)";
          alias="(.*)\\.gpg$";
        };
      };
    };
  }

#TODO
# Fill template:
#   ./test-store/email={domain={username={aliases="regex";};};};
# Exprected outcome:
#   domain = { outlook.com, web.de }
#   "outlook.com".username = outlook-username
#   "outlook.com".username.aliases = [ alias1 alias2 ]
#   "web.de".username = sascha.sanjuan
#   "web.de".username.alias = []
# Could merge this set with given home-manager config
#
# NOTE Give config via set. Every entry is applied via sorting of the filepath
#
#{
#  path = "...";
#  configs = rec { acc1={...}; acc2={...}; acc3=domain2; ...};
#  #NOTE domain3 uses the same config as domain2, but values are still
#  # indiviually supsitited
#}
#
#apply config={...} domain=.../email/web.de
