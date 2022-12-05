{ pkgs, lib, config, inputs, ... }:

{
  imports = [
    ../mixins/common.nix

    inputs.home-manager.nixosModules."home-manager"
  ];
  config = {
    home-manager.users.sam = {pkgs, ...}@hm: {
      home.stateVersion = "21.11";
    };
  };
}

