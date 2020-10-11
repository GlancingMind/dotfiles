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

    recReadDir = path: let
      fileset = builtins.readDir path;
      dirset = pkgs.lib.attrsets.filterAttrs (n: v: v == "directory") fileset;
      tree = builtins.mapAttrs (name: type: recReadDir (path+"/"+name)) dirset;
    in fileset // tree;

    getAttrsByDepth = path: dirset:
      builtins.attrNames (pkgs.lib.getAttrFromPath path dirset);

    domains = getAttrsByDepth [];
    usernames = domain: getAttrsByDepth [domain];

    # TODO map recursivly over template. Apply for each key getAttrsByDepth
    # like done for e.g. username. Replace value for this key with return of
    # getAttrsByDepth
    # NOTE want to say domain and get the list of domains.
    # By saying "domain 1" get the list of usernames of the first domain
    # So must assign domain the number 1, username the number 2, ...
    # This indices will be used to fetch values from dirset!
    resolve = set: let
      attrsList = builtins.attrNames set;
      # Given e.g. { a = ""; b = "" } => [ { a = 1; } { b = 2; } ]
      keyIndexSetList = pkgs.lib.lists.imap1 (i: v: { "${v}"=i;} ) attrsList;
      # Merges all sets in list to one set. { a = 1; b = 2; }
      keyIndexMap = pkgs.lib.lists.fold (a: b: a // b) {} keyIndexSetList;
    in
      keyIndexMap;

    getAttrByIndices = set: indices: let
      list = pkgs.lib.attrsets.mapAttrsToList (n: v: { "${n}"=v; } ) set;
      index = builtins.head indices;
      restIndices = builtins.tail indices;
      element = builtins.elemAt list index;
      # Retrieve value of element by unwraping it's only value via head.
      elementValue = builtins.head (builtins.attrValues element);
    in
      if restIndices == [] then
        element
      else
        getAttrByIndices elementValue restIndices;


    #NOTE will return [email [outlook.com [alias1 alias2]] [web.de [sascha.sanjuan]]]
    # Then replace this lists with their depth by using lists.imap
    # => [1 [ 1 [ 1 2 ]] [ 2 [ 1 ]]]
    # Or use builtins.elemAt for each given list element
    # => [ email [ ...] [ ]] elemAt foreach [ 1 1 2 ]
    # Above index access pattern [ 1 1 2 ] will be generated by using e.g.
    # [ domain username 2 ]...
    #attrs2ListRec = let
    #  set = recReadDir "/home/sascha/nix-config/user/module/test-store/email";
    #  values =
    #  #pkgs.lib.attrsets.mapAttrsRecursive
    #  #(n: v: list.imap pkgs.lib.attrsets.mapAttrsToList (pkgs.lib.attrsets.getAttrFromPath n))
    #in
    #  set;

    #NOTE
    # builtins.dirOf "(.*)" => ".";
    # builtins.dirOf "hello/(.*)" => "hello";
    # builtins.dirOf "/hello/(.*)" => "/hello";
    # Could use it to map regex to dirctory!

    #resolveValue = v: MatchFilesOrDefault {
    #    regex=v;
    #    files=recReadDir;
    #    default=v;};

    #resolve = {name, value}:
    #    pkgs.lib.attrsets.nameValuePair (resolveValue name) (resolveValue
    #    value);

    #mapping = pkgs.lib.mapAttrsRecursive
    #  (n: v: resolve {name=n; value=v;})
    #  rec {username="^(.*)"; aliases="${username}/(.*)\\.gpg$";};
  in
    #mapping;
    #usernames "web.de" (recReadDir "/home/sascha/nix-config/user/module/test-store/email");
    getAttrByIndices
      { hello=""; domain={ user=""; username={address="(.*)\\.gpg$"; }; };}
      [0 0];
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
