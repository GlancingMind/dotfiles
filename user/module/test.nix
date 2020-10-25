{pkgs ? import <nixpkgs> {}}:
let
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


  fill = template: schema:
    template (builtins.intersectAttrs (builtins.functionArgs template) schema);

  expand = {path, template, schema, ...}: let
    fileset = recReadDir path;
    paths = filesetToPaths fileset;
    nameValuePair = pkgs.lib.attrsets.nameValuePair;
    setTemplateAttrs = path: schema
    filledTemplates = map (file: nameValuePair
      (path+"/"+file) (fill template (schema//{template.path=path+"/"+file;}))) paths;
  in builtins.listToAttrs filledTemplates;

  removePrefix = pkgs.lib.strings.removePrefix;
in {
  #TODO 2. can use schema attrs, as direct set in template. => use default
  # params in template args! NOTE must then check, that every arg has a
  # default value! (already possible with functionArgs!
  config=expand {
    path="/home/sascha/.local/share/password-store/personal/email/web.de";
    schema = {
      foo="bar";
    };
    template = {foo, template}: let
      passwordStorePath = "/home/sascha/.local/share/password-store/";
      pass-name = removePrefix passwordStorePath template.path;
    in {
      hello=foo;
      passCmd="pass show ${pass-name}";
    };
  };
}
