{ pkgs ? import <nixpkgs> {}, lib ? pkgs.lib, ...}:
with pkgs.lib;

#NOTE maybe make package recursive and remove the need of buildPlugin
#NOTE loadOnDemandCode could return function which takes the plugin.name as
#argument.
#TODO how to add system binaries?
# - use extraPackages to depend on system binaries
#TODO instead of return builded vim plugins, return packaged vimPlugins!
# then merge plugins at the end into home-manager
#TODO add do command like vim-plug has
#TODO add preconfig, to apply configuration before plugin loading
#=======================================================================
#TODO allow to set dependencies to system binaries or other packages
#TODO the config of a optional loaded vim plugin should be only loaded on
# plugin load. E.g. load purescript-vim and it's config only on purescript
# files and don't concat it's config in the "global" vimrc.
#TODO create useXDGSpecification option in vim module, to store configs
#TODO write plugin config to file or store config file in nix store, then
# add to autocmd packadd! and source config
#NOTE Plugins which are on demand loaded via the commandPattern option,
# won't have working completion until the command is atleast invoked once.

let
  niv = builtins.mapAttrs (name: files: {
    inherit name;
    inherit files;
    source = builtins.fetchTarball {inherit (files) url sha256;};
  });
  nivTrackedPluginSources = niv (import ./nix/sources.nix {});

  config = builtins.readFile ./config/vimrc;
  pluginDeclarations = [
    {
      enable = true;
      name = "baker";
      config = builtins.readFile ./config/baker.vim;
      plugins = [nivTrackedPluginSources.vim-baker];
    }
    nivTrackedPluginSources.gruvbox
    {
      name = "editorconfig";
      plugins = [nivTrackedPluginSources.vim-editorconfig];
      config = builtins.readFile ./config/editorconfig.vim;
    }
    nivTrackedPluginSources.vim-nix
    nivTrackedPluginSources.vim-fugitive
    nivTrackedPluginSources.vim-surround
    {
      name = "vimwiki";
      plugins = [nivTrackedPluginSources.vimwiki];
      config = builtins.readFile ./config/vimwiki.vim;
    }
    #nivTrackedPluginSources."literate.vim"
    {
      name = "hardmode";
      plugins = [nivTrackedPluginSources.hardmode];
      config = builtins.readFile ./config/hardmode.vim;
      optional = {};
    }
    nivTrackedPluginSources.emmet-vim
    #nivTrackedPluginSources.vim-erlang-omnicomplete
    #nivTrackedPluginSources.vim-erlang-runtime
    #nivTrackedPluginSources.Ada-Bundle
    #nivTrackedPluginSources.psc-ide-vim
    #nivTrackedPluginSources.purescript-vim
    #nivTrackedPluginSources.vim-reason-plus
    {
      name = "LSP";
      config = builtins.readFile ./config/lsp.vim;
      plugins = [
        nivTrackedPluginSources.vim-lsp
        nivTrackedPluginSources."asyncomplete.vim"
        nivTrackedPluginSources."asyncomplete-lsp.vim"
      ];
      optional = {
        groupPluginsUnderName = true;
        loadOn = {
        #  filetypePatterns = ["beeb"];
        #  filenamePatterns = ["boo"];
        #  commandPatterns = ["BUB*" "Baker"];
        };
      };
    }
    pkgs.vimPlugins.fzf-vim
  ];

  package = plugin: let
    groupPluginsUnderName = plugins: name: let
      loadScript = pkgs.writeText "load-${name}-plugins.vim"
        (builtins.concatStringsSep "\n"
        (map (plugin: "packadd ${name}/${strings.getName plugin}") plugins));
    in pkgs.buildPackages.symlinkJoin  {
      #TODO find a way to not specify /share/vim-plugins
      inherit name;
      paths = plugins;
      postBuild = "
        # What is done here and why?
        # --------------------------
        # Take all plugins and group them under an artificially
        # create aggregate plugin, with the intent, that Vim won't any
        # longer display every plugin when using packadd, but instead
        # will only show the aggregate plugin. The user then only needs
        # to packadd the aggregate plugin, to load all the containing
        # child plugins. E.g.
        #   pack/lsp/opt/lsp-vim/{autoload,...}
        #   pack/lsp/opt/asyncomplete-vim/{autoload,...}
        #
        # Will become:
        #
        #   pack/lsp/opt/LSP/lsp-vim/{autoload,...}
        #   pack/lsp/opt/LSP/asyncomplete-vim/{autoload,...}
        #   pack/lsp/opt/LSP/plugin/load-plugins.vim
        #
        # NOTE: On packadd of LSP, Vim will load the load-plugins.vim
        # file, which then will call packadd for each plugin in
        # .../opt/LSP/. The load-plugins.vim file is required, as Vim
        # won't load other directories then the plugin one.
        # NOTE: Storing plugins inside plugin/, will load everything
        # inside the directory without a proper order, resulting in alot
        # of errors on some plugins (e.g. vimwiki)

        cd $out/share/vim-plugins
        mkdir .${name}  # need hidden Aggregate, so using * won't collide
        mv * .${name}   # move all plugins in hidden aggregate
        mv .${name} ${name} # make hidden aggregate visible

        # Create plugin directory with the needed plugin load script
        mkdir -p ${name}/plugin
        cp ${loadScript} ${name}/plugin
        ";
    };

    buildPluginDrvs = definition:
      if pkgs.lib.attrsets.isDerivation definition then
        [ definition ]
      else if definition ? plugins then
        #TODO are dependencies required here? can this be shortend?!
        lists.flatten (map buildPluginDrvs ((definition.plugins.dependencies or [])
          ++ (definition.plugins or [])))
      else [(pkgs.vimUtils.buildVimPluginFrom2Nix {
        inherit (definition) name;
        pname = definition.name;
        src = definition.source;
      })];

    # loadOn = {};
    #   => Plugin loads either itself or user must use :packadd
    # loadOn = { filetypePatterns, filenamePatterns, commandPatterns, ...};
    #   => Embed autocmd in vimrc to load plugin on given options
    # Unkown options will be ignored.
    loadOnDemandCode = settings: name: let
      augroup = "NixHomeManager-LoadOnDemand-${name}";
      loadPlugin = "packadd ${name}";
      # RemoveGroup will remove all registered autocmds of the group and itself
      #NOTE execute is needed otherwise "augroup!" will never be called!
      removeGroup = "execute 'autocmd! ${augroup}' | augroup! ${augroup}";
      autocmds = (pkgs.lib.attrsets.mapAttrsToList (event: patterns: let
        pattern = builtins.concatStringsSep "," patterns;
      in if event == "filetypePatterns" then
          "autocmd FileType ${pattern} ${loadPlugin} | ${removeGroup}"
        else if event == "filenamePatterns" then
          "autocmd BufNewFile,BufRead ${pattern} ${loadPlugin} | ${removeGroup}"
        else if event == "commandPatterns" then
          "autocmd CmdUndefined ${pattern} ${loadPlugin} | ${removeGroup}"
        else "\n") settings);
      configLines = lists.flatten [
        "augroup ${augroup}"
        "au!"
        autocmds
        "augroup END"
      ];
    in if settings == {} then ""
    else builtins.concatStringsSep "\n" configLines;

    config = plugin.config or "";
    lodCode = loadOnDemandCode (plugin.optional.loadOn or {}) plugin.name;
    plugins = if plugin.optional.groupPluginsUnderName or false
      then [ (groupPluginsUnderName (buildPluginDrvs plugin) plugin.name) ]
      else buildPluginDrvs plugin;
  in {
    name = "hm-${plugin.name}";
    value = if plugin ? optional
      then { opt = plugins; }
      else { start = plugins; };
    customRC = config + lodCode;
    inherit plugin;
  };

  packages = let
    enabledPlugins = builtins.filter (p: p.enable or true) pluginDeclarations;
  in rec {
    definitions = map package enabledPlugins;
    packages = builtins.listToAttrs definitions;
    configs = lists.remove "" (attrsets.catAttrs "customRC" definitions);
    customRC = config + (builtins.concatStringsSep "\n" configs);
  };

  vim = pkgs.vim_configurable.customize {
    name = "vim";
    vimrcConfig = { inherit (packages) packages customRC; };
  };
in {
  #inherit packages;
  #inherit nivTrackedPluginSources;
  home.packages = [ vim ];
}
