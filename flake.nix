{
  description = "sam's flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    utils.url = "github:numtide/flake-utils";
    impermanence.url = "github:nix-community/impermanence";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    agenix.url = "github:ryantm/agenix";
    jj.url = "github:martinvonz/jj";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    site = {
      url = "github:samhza/samhza.com";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "utils";
    };
  };

  outputs = inputs: let
    pkgs = inputs.nixpkgs.legacyPackages."x86_64-linux";
    mkSystem_ = pkgs: system: h: modules:
      pkgs.lib.nixosSystem {
        system = system;
        modules = [./hosts/${h}/configuration.nix] ++ modules;
        specialArgs = {inherit inputs;};
      };
    mkSystem = pkgs: system: h: (mkSystem_ pkgs system h [
        inputs.agenix.nixosModule
      ]);
  in {
    nixosConfigurations = {
      lilith = mkSystem inputs.nixpkgs "x86_64-linux" "lilith";
      ramiel = mkSystem inputs.nixpkgs "x86_64-linux" "ramiel";
    };

    devShells.x86_64-linux.default = pkgs.mkShell {
      buildInputs = [
        inputs.agenix.packages.x86_64-linux.agenix
        pkgs.nix
        pkgs.nixos-rebuild
      ];
    };
  };
}
