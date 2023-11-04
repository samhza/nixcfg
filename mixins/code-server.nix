{
  lib,
  config,
  options,
  pkgs,
  inputs,
  ...
}:
{
  services.code-server = {
    enable = true;
    user = "sam";
  };
  nixpkgs.config.permittedInsecurePackages = [
    "nodejs-16.20.2"
  ];
  home-manager.users.sam = {pkgs, ...}@hm: {
 #   home.packages = [ pkgs.vscode ];
    imports = [ inputs.vscode-server.homeModules.default ];
    services.vscode-server.enable = true;

  };
  nixpkgs.config.allowUnfree = true;
}
