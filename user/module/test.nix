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
  EvaluateTemplate = {path, filestructure, template}: let

    recReadDir = path: let
      fileset = builtins.readDir path;
      dirset = pkgs.lib.attrsets.filterAttrs (n: v: v == "directory") fileset;
      tree = builtins.mapAttrs (name: type: recReadDir (path+"/"+name)) dirset;
    in fileset // tree;

    # TODO convert list of access names to access pattern e.g.
    # domain={username...} => username => [[] 1] => match username pattern
    # which will be used to get the attribute by indices from recReadDir

    # { hello=""; domain={ user=""; username={address="(.*)\\.gpg$"; }; };};
    # username should convert to [ 0 1 ]
    resolveRec = set: let
      recDepth = builtins.length;
      prevPath = attrPath: builtins.tail (pkgs.lib.lists.reverseList attrPath);
    in pkgs.lib.attrsets.mapAttrsRecursive
      (attrPath: v: (recDepth attrPath)+recDepth(prevPath attrPath)) set;

    getIndex = set: attri: let
      names = builtins.attrNames set;
      # Given e.g. { a = ""; b = "" } => [ { a = 1; } { b = 2; } ]
      listOfKeyIndexSet = pkgs.lib.lists.imap0 (i: v: {${v} = i;}) names;
      # Merges all sets in list to one set. { a = 1; b = 2; }
      indexSet = pkgs.lib.lists.fold (a: b: a // b) {} listOfKeyIndexSet;
    in
      builtins.getAttr attri indexSet;

    # Converts an attribute access path [ domain username ]
    # to an index access path [ 0 1 ]
    attrPathToIndexPath = set: attriList: let
      key = builtins.head attriList;
      index = getIndex set key;
      tail = builtins.tail attriList;
      subset = builtins.getAttr key set;
    in
      if tail == [] then
        [ index ]
      else
        [ index ] ++  (attrPathToIndexPath subset tail);

    getAttrByIndicesPath = set: indices: let
      list = pkgs.lib.attrsets.mapAttrsToList (n: v: { "${n}"=v; } ) set;
      index = builtins.head indices;
      restIndices = builtins.tail indices;
      element = builtins.elemAt list index;
      # Retrieve value of element by unwraping it's only value via head.
      elementValue = builtins.head (builtins.attrValues element);
    in
      if index == [] then
        builtins.attrNames set
      else if restIndices == [] then
        element
      else
        getAttrByIndicesPath elementValue restIndices;

    getAttrNameByIndicesPath = set: indices:
      builtins.head (builtins.attrNames (getAttrByIndicesPath set indices));

    unfold = set:
      builtins.concatLists
      (builtins.attrValues
        (builtins.mapAttrs (n: v: map (value: { ${n} = value; }) v)
        set));

    fill = path: let
      # get value for attrName from reading filestructure
      fileset = builtins.readDir path;
      dirset = pkgs.lib.attrsets.filterAttrs (n: v: v == "directory") fileset;
      dirnames = builtins.attrNames dirset;
      # Gives: { username = [ "outlook.com" "web.de" ]; }
      attrFileMap = pkgs.lib.attrsets.mapAttrs (n: v: dirnames) filestructure;
      # will be unfolded via unfold
      attrs = unfold attrFileMap;

      # TODO Foreach "username" create copy of template and fill in

      # TODO add address
    #in map (dir: (attrs ++ fill (path+"/"+dir))) dirnames;
    in attrFileMap;
  in
    #recReadDir "/home/sascha/nix-config/user/module/test-store/email";
    #resolveRec { hello=""; domain={ user=""; username={address="(.*)\\.gpg$"; }; };};
    #attrPathToIndexPath
    #  { hello=""; domain.user=""; domain.username={address="(.*)\\.gpg$"; }; }
    #  [ "domain" "username" "address" ];
    #getAttrByIndicesPath
    #  (recReadDir "/home/sascha/nix-config/user/module/test-store/email")
    #  [ 2 [] ];
    #genAccessPattern {"domain" = "";};
    fill "/home/sascha/nix-config/user/module/test-store/email/outlook.com";
in
  {
    outlook=EvaluateTemplate {
      path="/home/sascha/nix-config/user/module/test-store/email/outlook.com";
      filestructure = { username = { address = "(.*)\\.gpg$"; }; };
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
