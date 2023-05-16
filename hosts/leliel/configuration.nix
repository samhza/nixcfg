{
  config,
  lib,
  pkgs,
  modulesPath,
  inputs,
  ...
}: {
  imports = [
    ../../profiles/interactive.nix
    ../../profiles/security.nix
    ../../profiles/network.nix
    ../../profiles/graphical.nix
    ../../profiles/sway
    ../../mixins/greetd.nix
    ../../mixins/pipewire.nix
    ../../mixins/gtk.nix
    ../../mixins/kanata.nix
    ../../mixins/gnupg.nix
    ../../mixins/helix.nix
    ../../mixins/tailscale.nix
    ./hardware-configuration.nix

    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-6th-gen
  ];
  config = {
    networking = {
      hostName = "leliel";
    };
    services.kanata.keyboards.colemak.devices = [ "/dev/input/by-path/platform-i8042-serio-0-event-kbd" ];
    networking.firewall.checkReversePath = "loose";
    networking.nftables.enable = true;
    networking.wireguard.enable = true;
    services.mullvad-vpn.enable = true;
    programs.sway.enable = true;
    programs.dconf.enable = true;
    home-manager.users.sam = {pkgs, ...} @ hm: {
      programs.foot.settings = {
        main.font = lib.mkForce "Iosevka Comfy Fixed:size=10";
        colors = {
          foreground = "dcdccc";
          background = "111111";

          regular0 = "222222";  # black
          regular1 = "cc9393";  # red
          regular2 = "7f9f7f";  # green
          regular3 = "d0bf8f";  # yellow
          regular4 = "6ca0a3";  # blue
          regular5 = "dc8cc3";  # magenta
          regular6 = "93e0e3";  # cyan
          regular7 = "dcdccc";  # white

          bright0 = "666666";   # bright black
          bright1 = "dca3a3";   # bright red
          bright2 = "bfebbf";   # bright green
          bright3 = "f0dfaf";   # bright yellow
          bright4 = "8cd0d3";   # bright blue
          bright5 = "fcace3";   # bright magenta
          bright6 = "b3ffff";   # bright cyan
          bright7 = "ffffff";   # bright white
        };
      };


      systemd.user.services."logseq-sync" = {
        Unit.Description = "sync logseq ~/knowledge";
        Service = {
          Type = "oneshot";
          Environment = [
            "PATH=${lib.makeBinPath (with pkgs; [openssh git])}"
          ];
          WorkingDirectory = "/home/sam/knowledge";
          ExecStart = "${pkgs.writeShellScript "logseq-sync"
            ''
              #!/bin/sh -eu
              git pull --ff-only
              git push
            ''}";
        };
      };
      systemd.user.timers."logseq-sync" = {
        Unit.Description = "sync logseq ~/knowledge";
        Timer = {
          OnBootSec = "1m";
          OnUnitInactiveSec = "1m";
          Unit = "logseq-sync.service";
        };
        Install.WantedBy = ["default.target"];
      };
      
      home.sessionVariables = {
        EDITOR = "nvim";
        SSH_AUTH_SOCK = "/run/user/1000/keyring/ssh";
      };
      wayland.windowManager.sway.config.seat."*".xcursor_theme ="macOS-BigSur-White 26";
      home.sessionPath = [ "$HOME/go/bin" "$HOME/.cargo/bin" ];
      home.packages = with pkgs; [
        # ciscoPacketTracer8
        rust-analyzer
        appimage-run
        apple-cursor
        vivaldi
        vivaldi-ffmpeg-codecs
        xdg-utils
        discord
        (pkgs.writeShellApplication {
          name = "logseq";
          text = "${pkgs.logseq}/bin/logseq --enable-features=UseOzonePlatform --ozone-platform=wayland";
        })
      ];
      xdg.userDirs = let
        inherit (config.home-manager.users.sam.home) homeDirectory;
        inherit (config.home-manager.users.sam.xdg) configHome dataHome;
      in {
        enable = true;
        desktop = "${dataHome}/desktop";
        documents = "${homeDirectory}/doc";
        download = "${homeDirectory}/tmp";
        music = "${homeDirectory}/music";
        pictures = "${homeDirectory}/images";
        publicShare = "${homeDirectory}/public";
        templates = "${configHome}/templates";
        videos = "${homeDirectory}/videos";
      };
      programs.gh.enable = true;
      programs.git = {
        userName = "Samuel Hernandez";
        userEmail = "sam@samhza.com";
        enable = true;
        extraConfig.core.excludesfile = "~/.config/git/ignore";
        ignores = [
          "flake.nix"
          "flake.lock"
          ".direnv"
          ".envrc"
        ];
      };

      nixpkgs.config = {allowUnfree = true;};
      xdg.configFile."nixpkgs/config.nix".text = "{ allowUnfree = true; }";
      programs.alacritty.enable = true;
      programs.password-store = {
        enable = true;
        package = pkgs.pass.withExtensions (exts: [exts.pass-otp]);
        settings.PASSWORD_STORE_DIR = "$HOME/secrets/password-store";
        settings.PASSWORD_STORE_GENERATED_LENGTH = "24";
        settings.PASSWORD_STORE_CHARACTER_SET = "abcdefghijklmnopqrstuvwxyz";
      };
      programs.browserpass = {
        enable = true;
        browsers = ["chrome"];
      };
      programs.nix-index = {
        enable = true;
        enableFishIntegration = true;
      };
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
    };

    nixpkgs.config.allowUnfree = true;

    networking.networkmanager.enable = true;

    hardware.pulseaudio.enable = false;
    boot.loader.systemd-boot.consoleMode = "max";
    boot.kernelParams = [ "quiet" ];
    console.keyMap = "${pkgs.colemak-dh}/share/keymaps/i386/colemak/colemak_dh_ansi_us.map";

    boot.loader.efi.efiSysMountPoint = "/boot/esp";
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.initrd.luks.devices = {
      root = {
        device = "/dev/disk/by-uuid/6e76474f-a83e-4ab3-8264-611b2e39300d";
        preLVM = true;
        allowDiscards = true;
      };
    };

    hardware.enableRedistributableFirmware = true;

    system.stateVersion = "22.11";
  };
}
