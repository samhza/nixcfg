{ pkgs, lib, config, inputs, ... }:

{
  imports = [
    ../mixins/common.nix

    inputs.home-manager.nixosModules."home-manager"
  ];
  config = {
    nix = {
      registry.nixpkgs.flake = inputs.nixpkgs;
      gc.automatic = true;
      optimise.automatic = true;
      settings = {
        auto-optimise-store = true;
        sandbox = true;
        allowed-users = ["@wheel"];
        trusted-users = ["root" "@wheel"];
      };
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };
    home-manager.users.sam = {pkgs, ...}@hm: {
      home.stateVersion = "21.11";
    };
  };
}

