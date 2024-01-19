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
    # ../../mixins/greetd.nix
    # ../../profiles/kde
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
    services.kanata.keyboards.colemak.devices = [ "/dev/input/by-path/platform-i8042-serio-0-event-kbd" "pci-0000:00:1f.4-serio-2-event-mouse" ];
    services.ipfs.enable = true;
    networking.firewall.checkReversePath = "loose";
    systemd.services.NetworkManager-wait-online.enable = false;
    systemd.services."failure-handler@" = {
      description ="failure handler for %i";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "/home/sam/failurehandler %i";
      };
    };
    systemd.packages = [
      (pkgs.runCommandNoCC "toplevel-overrides.conf" {
        preferLocalBuild = true;
        allowSubstitutes = false;
      } ''
        mkdir -p $out/etc/systemd/system/service.d/
        echo "[Unit]" >> $out/etc/systemd/system/service.d/toplevel-overrides.conf
        echo "OnFailure=failure-handler@%N.service" >> $out/etc/systemd/system/service.d/toplevel-overrides.conf
      '')
    ];
    boot.plymouth.enable = true;
    networking.nftables.enable = true;
    networking.wireguard.enable = true;
    services.mullvad-vpn.enable = true;
    services.upower.enable = true;
    hardware.bluetooth.enable = true;
    services.fprintd.enable = true;
    programs.sway.enable = true;
    programs.dconf.enable = true;
    programs.steam = {
      enable = true;
    };
    systemd.sleep.extraConfig = "HibernateDelaySec=1h";
    services.logind.lidSwitch = "suspend-then-hibernate";
    services.logind.lidSwitchDocked = "ignore";
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

      nixpkgs.config.permittedInsecurePackages = [
        "electron-25.9.0"
      ];
      home.sessionVariables = {
        EDITOR = "hx";
        SSH_AUTH_SOCK = "/run/user/1000/keyring/ssh";
      };
      wayland.windowManager.sway.config.seat."*".xcursor_theme ="macOS-BigSur-White 26";
      home.sessionPath = [ "$HOME/go/bin" "$HOME/.cargo/bin" ];
      home.packages = with pkgs; [
        fzf
        jq
        gopls
        gotools
        # (inputs.nix-matlab.packages.x86_64-linux.matlab)
        nodejs
        yt-dlp
        python3
        gopls
        rlwrap
        zathura
        ghostscript
        go
        rclone
        chromium
        spotify
        rust-analyzer
        appimage-run
        apple-cursor
        # (pkgs.callPackage ../../pkgs/beeper-desktop.nix {} )
        (pkgs.vivaldi.override {
          commandLineArgs = ["--force-dark-mode"];
        })
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
      programs.gh.settings.version = 1;
      programs.git = {
        userName = "Samuel Hernandez";
        userEmail = "sam@samhza.com";
        enable = true;
        extraConfig.core.excludesfile = "~/.config/git/ignore";
        # ignores = [
        #   "flake.nix"
        #   "flake.lock"
        #   ".direnv"
        #   ".envrc"
        # ];
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
    services.undervolt = {
      coreOffset = -90;
      enable = true;
    };

    nixpkgs.config.allowUnfree = true;

    networking.networkmanager.enable = true;

    hardware.pulseaudio.enable = false;
    boot.loader.systemd-boot.consoleMode = "max";
    boot.loader.systemd-boot.extraInstallCommands = ''
      echo "reboot-for-bitlocker yes" >> /boot/loader/loader.conf
    '';
    boot.kernelParams = [ "quiet" ];
    console.keyMap = "${pkgs.colemak-dh}/share/keymaps/i386/colemak/colemak_dh_ansi_us.map";

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    hardware.enableRedistributableFirmware = true;

    system.stateVersion = "23.11";
  };
}
