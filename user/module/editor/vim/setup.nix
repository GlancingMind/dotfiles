{ pkgs ? import <nixpkgs> {}, ...}:

#TODO sort optional plugins, as they must be set in optional
#TODO the config of a optional loaded vim plugin should be only loaded on
# plugin load. E.g. load purescript-vim and it's config only on purescript
# files and don't concat it's config in the "global" vimrc.
#TODO allow to set dependencies to system binaries or other packages
#TODO create useXDGSpecification option in vim module, to store configs
#NOTE allowing a path for plugin config isn't consistent to extraConfig options

let
  nivTrackedPluginSources = import ./nix/sources.nix {};
  nivPlugins = import ./plugins.nix {};
  config = builtins.readFile ./config/vimrc;
  plugins = [
    {
      enable = true;
      source = nivTrackedPluginSources.vim-baker;
      config = ./config/baker.vim;
      loadOn = {};
    }
    { source = nivTrackedPluginSources.gruvbox; }
    { source = nivTrackedPluginSources.vim-editorconfig; }
    {
      source = nivTrackedPluginSources.vim-nix;
      loadOn = {
        filetypeRegEx = "FT";
        filenameRegEx = "FN";
        tag = "BLUB";
      };
    }
    #{ source = nivTrackedPluginSources.vim-fugitive; }
    #{ source = nivTrackedPluginSources.vim-surround; }
    #{ source = nivTrackedPluginSources.vimwiki; }
    #{ source = nivTrackedPluginSources."literate.vim"; }
    #{ source = nivTrackedPluginSources.hardmode; }
    #{ source = nivTrackedPluginSources.emmet-vim; }
    #{ source = nivTrackedPluginSources.vim-erlang-omnicomplete; }
    #{ source = nivTrackedPluginSources.vim-erlang-runtime; }
    #{ source = nivTrackedPluginSources.Ada-Bundle; }
    #{ source = nivTrackedPluginSources.psc-ide-vim; }
    #{ source = nivTrackedPluginSources.purescript-vim; }
    #{ source = nivTrackedPluginSources.vim-reason-plus; }
    #{ sources = [
    #    nivTrackedPluginSources.vim-lsp
    #    nivTrackedPluginSources."asyncomplete.vim"
    #    nivTrackedPluginSources."asyncomplete-lsp.vim"
    #  ];
    #}
  ];

  isEnabled = plugin: (plugin ? enable) -> plugin.enable;
  enabledPlugins = builtins.filter isEnabled plugins;

  # loadOn = {};
  #   => Plugin loads either itself or user must use :packadd
  # loadOn = { filetypeRegEx, filenameRegEx, tag, ...};
  #   => Embed autocmd in vimrc to load plugin on given options
  # Unkown options will be ignored.
  isLoadedOnDemand = builtins.hasAttr "loadOn";
  onDemandLoadedPlugins = builtins.filter isLoadedOnDemand enabledPlugins;
  genLoadOnCmdCode = plugin: let
    genAutoCmds = option: regex:
      if option == "filetypeRegEx"
        then "\"load plugin via filetype ${regex}"
      else if option == "filenameRegEx"
        then "\"load plugin via filename ${regex}"
      else if option == "tag"
        then "\"load plugin via tag ${regex}"
      else "";
  in builtins.concatStringsSep "\n"
    (pkgs.lib.attrsets.mapAttrsToList genAutoCmds plugin.loadOn);

  hasConfig = plugin: (plugin ? config);
  getConfig = plugin: if builtins.isPath plugin.config
    then builtins.readFile plugin.config
    else plugin.config;

  # Represents the whole configuration of every enabled plugin configuration.
  consolidatePluginConfig = let
    enabledPluginsWithConfig = builtins.filter hasConfig enabledPlugins;
    configs = map getConfig enabledPluginsWithConfig;
  in builtins.concatStringsSep "\n" configs;

  # Strips the "/nix/store/<hash>-" and "-src" of a store path.
  # E.g. /nix/store/nj95f79qx09i7lg90an71mqh635hp1jx-vim-baker-src
  # will become vim-baker
  parseNameFromStorePath = path: let
    matches = builtins.match "[^-]+-(.+)-src" (builtins.toString path);
    # NOTE match will return a list, which should contain only 1 element, but
    # it might be safer to not use builtins.head and instead convert the list
    # to a string.
  in builtins.toString (matches);

  nivSourceToVimPlugin = pluginSource: let
    name = parseNameFromStorePath pluginSource.outPath;
  in pkgs.vimUtils.buildVimPluginFrom2Nix {
    inherit name;
    pname = name;
    src = builtins.fetchTarball { inherit (pluginSource) url sha256; };
  };

  convertedPlugins = sources: let
    convert = plugin:
      if plugin ? sources
      then map nivSourceToVimPlugin plugin.sources
      else nivSourceToVimPlugin plugin.source;
      #TODO maybe make a else case with error handling (require source/sources)
    converted = map convert sources;
  in pkgs.lib.flatten converted;

  vim = let
    onDemandCode = builtins.toString (map genLoadOnCmdCode onDemandLoadedPlugins);
    customRC = config + consolidatePluginConfig + onDemandCode;
  in pkgs.vim_configurable.customize {
    name = "custom-vim";
    vimrcConfig = {
      inherit customRC;
      packages.home-manager.start = convertedPlugins enabledPlugins;
      packages.home-manager.opt = convertedPlugins onDemandLoadedPlugins;
      #TODO check if lsp has it's own plugin directory
    };
  };
in {
  home.packages = [ vim ];
}
