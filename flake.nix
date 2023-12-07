{
  description = "sam's flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    impermanence.url = "github:nix-community/impermanence";
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixpkgs-wayland = { url = "github:nix-community/nixpkgs-wayland/master"; inputs."nixpkgs".follows = "nixpkgs"; };
    agenix = { url = "github:ryantm/agenix"; inputs."nixpkgs".follows = "nixpkgs"; };
    jj.url = "github:martinvonz/jj";
    nix-matlab.url = "gitlab:doronbehar/nix-matlab";
    nix-matlab.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    helix.url = "github:helix-editor/helix/23.03";
    vscode-server = { url = "github:nix-community/nixos-vscode-server"; inputs."nixpkgs".follows = "nixpkgs"; };
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
        inputs.agenix.nixosModules.default
      ]);
  in {
    nixosConfigurations = {
      lilith = mkSystem inputs.nixpkgs "x86_64-linux" "lilith";
      leliel = mkSystem inputs.nixpkgs "x86_64-linux" "leliel";
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
