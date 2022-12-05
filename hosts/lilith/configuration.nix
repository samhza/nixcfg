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
    ../../profiles/sway
    ../../profiles/graphical.nix
    ../../mixins/greetd.nix
    ../../mixins/gfx-nvidia.nix
    ../../mixins/gnupg.nix
    ../../mixins/easyeffects.nix
    ../../mixins/spotify.nix
    ../../mixins/pipewire.nix
    ../../mixins/tailscale.nix

    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    # inputs.nixos-hardware.nixosModules.common-gpu-nvidia
  ];
  config = {
    networking = {
      hostName = "lilith";
    };
    programs.dconf.enable = true;
    home-manager.users.sam = {pkgs, ...} @ hm: {
      home.sessionVariables = {
        EDITOR = "nvim";
        SSH_AUTH_SOCK = "/run/user/1000/keyring/ssh";
      };
      home.sessionPath = [ "$HOME/go/bin" "$HOME/.cargo/bin" ];
      programs.neovim = {
        enable = true;
        plugins =
        with pkgs.vimPlugins; [
          ale
          ctrlp
          copilot-vim
        ];
      };
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
      wayland.windowManager.sway.config.output."DP-1".resolution = "1920x1080@166Hz";
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
      programs.git = {
        userName = "samhza";
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
      home.packages = with pkgs; [
        (inputs.jj.outputs.packages.${pkgs.system}.jujutsu)
        go
        gopls
        delve
        gcc
        gimp
        gdu
        vivaldi
        rustup
        openssl
        pkgconfig
        pkg-config
        git-branchless
        github-cli
        ffmpeg
        xdg-utils
        jq
        jo
        openssh
        file
        rclone
        yt-dlp
        alejandra
        (pkgs.writeShellApplication {
          name = "code";
          text = "${pkgs.vscode}/bin/code --enable-features=UseOzonePlatform --ozone-platform=wayland \"$@\"";
        })
        (pkgs.writeShellApplication {
          name = "jjgit";
          text = "git --git-dir .jj/repo/store/git \"$@\"";
        })
        (pkgs.writeShellApplication {
          name = "logseq";
          text = "${pkgs.logseq}/bin/logseq --enable-features=UseOzonePlatform --ozone-platform=wayland";
        })
        (pkgs.writeShellApplication {
          name = "discord";
          text = "${(pkgs.discord.override {withOpenASAR = true;})}/bin/discord --use-gl=desktop";
        })
        (pkgs.makeDesktopItem {
          name = "discord";
          exec = "discord";
          desktopName = "Discord";
        })
        (stdenv.mkDerivation{
          pname = "spr";
          version = "0.9.2";
          src = fetchzip {
            url = "https://github.com/ejoffe/spr/releases/download/v0.9.2/spr_linux_x86_64.tar.gz";
            stripRoot = false;
            sha256 = "sha256-hNNUx7q7VhxMhhkHK5d68jPanYOJMddF9bs4FimD5vY=";
          };
          installPhase = ''
            install -m755 -D git-spr $out/bin/git-spr
            install -m755 -D spr_reword_helper $out/bin/spr_reword_helper
          '';
        })
        gomuks
      ];
    };

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

    nixpkgs.config.allowUnfree = true;

    networking.networkmanager.enable = true;

    services.postgresql.enable = true;
    services.postgresql.authentication = pkgs.lib.mkOverride 10 ''
      local all all trust
      hostnossl all all 0.0.0.0/0 trust
      hostnossl all all ::1/128 trust
    '';

    services.caddy = {
      enable = true;
      extraConfig = ''
        :80 {
          @public not remote_ip forwarded 100.64.0.0/10 127.0.0.1/8 ::1
          handle_path /tmp/* {
            root * /4tb/tmp
            file_server
          }
          handle /* {
            respond @public 401
            root * /
            file_server browse
          }
        }
      '';
    };

    services.xserver.videoDrivers = ["nvidia"];
    hardware.pulseaudio.enable = false;

    virtualisation.libvirtd.enable = true;

    users.users.sam = {
      isNormalUser = true;
      extraGroups = ["wheel"];
      packages = with pkgs; [
        firefox
        discord
        (pkgs.google-chrome.override {
          commandLineArgs = ["--force-dark-mode"];
        })
        thunderbird
        neovim
        git
      ];
    };

    boot.initrd.availableKernelModules = ["xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod"];
    boot.initrd.kernelModules = ["dm-snapshot"];
    boot.kernelModules = ["kvm-amd"];
    boot.extraModulePackages = [];
    boot.loader.efi.efiSysMountPoint = "/boot/esp";
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.initrd.luks.devices = {
      root = {
        device = "/dev/disk/by-uuid/79409afc-74ff-4b41-ba85-e7833801be1f";
        preLVM = true;
        allowDiscards = true;
      };
    };

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/e6b5323b-bc1d-4543-aa64-f661cb35afaf";
      fsType = "ext4";
      options = ["noatime" "nodiratime" "discard"];
    };
    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/61f077ff-9d28-4fcd-9d76-425fb0f780af";
      fsType = "ext4";
    };
    fileSystems."/boot/esp" = {
      device = "/dev/disk/by-uuid/41E3-6688";
      fsType = "vfat";
    };
    fileSystems."/4tb" = {
      device = "/dev/disk/by-uuid/1d24154d-270c-4cc7-9c1c-1a7c0d65d238";
      fsType = "ext4";
    };

    swapDevices = [{device = "/dev/disk/by-uuid/72b6d1c6-eb62-492a-99f1-b29850061a00";}];

    hardware.enableRedistributableFirmware = true;
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    hardware.video.hidpi.enable = lib.mkDefault true;

    system.stateVersion = "22.05";
  };
}
