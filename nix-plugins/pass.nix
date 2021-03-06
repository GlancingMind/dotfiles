{ exec, pkgs ? import <nixpkgs> {}, ...  }:

with pkgs.lib;

let
  pass = pkgs.writeScript "nix-read-from-pass.sh" ''
      #! /usr/bin/env bash

      PASSWORD_STORE_DIR="$1"

      set -euo pipefail

      f=$(mktemp)
      trap "rm $f" EXIT
      ${pkgs.pass}/bin/pass show "$2" > $f
      nix-instantiate --eval --expr "builtins.readFile $f"
    '';

  pwStorePath = if builtins.getEnv "PASSWORD_STORE_DIR" == ""
    then "$XDG_DATA_HOME/password-store"
    else builtins.getEnv "PASSWORD_STORE_DIR";

  files = inStorePath: let
    fileset = builtins.readDir "${pwStorePath}/${inStorePath}";
    files = attrsets.filterAttrs (n: v: v != "directory") fileset;
    filenames = builtins.attrNames fileset;
  in
    map (strings.removeSuffix ".gpg") filenames;

  raw = file: exec [pass pwStorePath file];

  lines = file: let
    asListOfLines = text: builtins.split "\n" text;
    isEmpty = item: item == [] || item == "" || item == null;
    ignoreEmptyLines = builtins.filter (item: !isEmpty item);
  in trivial.pipe (raw file) [asListOfLines ignoreEmptyLines];

  line = number: file: builtins.elemAt (lines file) (number - 1);

  lookup = pattern: file: let
    interleavedMatches = map (builtins.match pattern) (lines file);
    preciseMatches = lists.remove null interleavedMatches;
  in lists.flatten preciseMatches;

  lookupFirst = pattern: file: builtins.head (lookup pattern file);
in {
  pass = {
    inherit pwStorePath;
    inherit files;
    decrypt = {
      inherit raw;
      inherit line;
      inherit lines;
      inherit lookup;
      inherit lookupFirst;
    };
  };
}
