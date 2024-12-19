{ pkgs, lib, config, inputs, ... }:

{
  imports = [
    ./core.nix
  ];
  config = {
    services.dbus.packages = with pkgs; [ pkgs.dconf ];
    home-manager.users.sam = {pkgs, ...}@hm: {
      home.packages = with pkgs; [
        rsync
        nano
        wget
        curl
        fd
        ripgrep
        tmux
        htop
        unzip
      ];
      programs.ssh = {
        enable = true;
      };
      programs.fish = {
        enable = true;
        shellInit = ''
          set fish_greeting
        '';
        interactiveShellInit = ''
        function mark_prompt_start --on-event fish_prompt
            echo -en "\e]133;A\e\\"
        end
        function foot_cmd_start --on-event fish_preexec
            echo -en "\e]133;C\e\\"
        end
        
        function foot_cmd_end --on-event fish_postexec
            echo -en "\e]133;D\e\\"
        end
        '';
        shellAliases = {
          gc = "git clone";
          l = "ls -alh --group-directories-first";
        };
        functions = {
          nd = "nix develop -c $SHELL";
          nr = "nix run nixpkgs#$argv[1] -- $argv[2..-1]";
          ns = "nix shell (for prog in $argv; echo \"nixpkgs#$prog\"; end)";
          nsw = "nix shell (for prog in $argv; echo \"weekly#$prog\"; end)";
          nrw = "nix shell (for prog in $argv; echo \"weekly#$prog\"; end)";
          c = "wl-copy";
          v = "wl-paste";
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

