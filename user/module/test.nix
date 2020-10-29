{pkgs ? import <nixpkgs> {}}:
with pkgs.lib;
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

  expand = {path, do}: let
    fileset = recReadDir path;
    paths = filesetToPaths fileset;
  in map (file: do {expandedPath=path+"/"+file;}) paths;
in {
  inherit expand;
}
