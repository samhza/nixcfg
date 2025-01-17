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
    # nix-matlab.url = "gitlab:doronbehar/nix-matlab";
    # nix-matlab.inputs.nixpkgs.follows = "nixpkgs";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";
    esammy.url = "github:samhza/esammy/trunk";
    esammy.flake = false;
    govanity.url = "github:samhza/govanity/trunk";
    govanity.flake = false;
    logseq.url = "github:logseq/logseq/feat/db";
    logseq.flake = false;
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    helix.url = "github:helix-editor/helix/23.03";
    vscode-server = { url = "github:nix-community/nixos-vscode-server"; inputs."nixpkgs".follows = "nixpkgs"; };
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.3.0";
    nix-gaming.url = "github:fufexan/nix-gaming";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    nix-minecraft.inputs.nixpkgs.follows = "nixpkgs";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    emacs-overlay.inputs.nixpkgs.follows = "nixpkgs";
    catppuccin.url = "github:catppuccin/nix";
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
      bardiel = mkSystem inputs.nixpkgs "aarch64-linux" "bardiel";
      installer = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [./installer.nix];
        specialArgs = {inherit inputs;};
      };
      test = mkSystem inputs.nixpkgs "arm64-linux" "leliel";
    };

    devShells.x86_64-linux.default = pkgs.mkShell {
      buildInputs = [
        inputs.agenix.packages.x86_64-linux.agenix
        pkgs.nil
        pkgs.nix
        pkgs.nixos-rebuild
      ];
    };
  };
}
