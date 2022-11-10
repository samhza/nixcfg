{
  description = "sam's flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    impermanence.url = "github:nix-community/impermanence";
    hardware.url = "github:nixos/nixos-hardware";
    agenix.url = "github:ryantm/agenix";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs: let
    mkSystem_ = pkgs: system: h: modules:
      pkgs.lib.nixosSystem {
        system = system;
        modules = [./hosts/${h}/configuration.nix] ++ modules;
        specialArgs = {inherit inputs;};
      };
    mkSystem = pkgs: system: h: (mkSystem_ pkgs system h [inputs.home-manager.nixosModules.home-manager inputs.agenix.nixosModule]);
  in {
    nixosConfigurations = {
      lilith = mkSystem inputs.nixpkgs "x86_64-linux" "lilith";
    };
  };
}