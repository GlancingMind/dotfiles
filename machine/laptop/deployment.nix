{
  laptop = { ... }: {
    deployment.targetHost = "127.0.0.1";
    imports = [./hardware-configuration.nix ./configuration.nix];
  };
}
