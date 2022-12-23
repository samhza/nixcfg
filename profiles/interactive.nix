{ pkgs, lib, config, inputs, ... }:

{
  imports = [
    ./core.nix
  ];
  config = {
    home-manager.users.sam = {pkgs, ...}@hm: {
      home.packages = with pkgs; [
        rsync
        nano
        wget
        curl
        fd
        ripgrep
      ];
      programs.ssh = {
        enable = true;
        matchBlocks.jascha = {
          hostname = "doorcraft.de";
          port = 44303;
        };
        matchBlocks.dm4.hostname = "balls.dm4uz3.pt";
        matchBlocks.ramiel.hostname = "5.161.55.25";
      };
      programs.fish = {
        enable = true;
        shellInit = ''
          set fish_greeting
        '';
        shellAliases = {
          gc = "git clone";
          l = "ls -alh";
          nr = "nix run nixpkgs#$1";
          ns = "nix shell nixpkgs#$1";
        };
        functions = {
          sb.body = "sudo nixos-rebuild build --flake ~/sources/nixcfg#(hostname)";
          sw.body = "sudo nixos-rebuild switch --flake ~/sources/nixcfg#(hostname)";
        };
        plugins = [
          {
            name = "z";
            src = pkgs.fetchFromGitHub {
              owner = "jethrokuan";
              repo = "z";
              rev = "ddeb28a7b6a1f0ec6dae40c636e5ca4908ad160a";
              sha256 = "0c5i7sdrsp0q3vbziqzdyqn4fmp235ax4mn4zslrswvn8g3fvdyh";
            };
          }
        ];
      };
    };
  };
}

