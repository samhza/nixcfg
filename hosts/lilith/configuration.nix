{
  config,
  lib,
  pkgs,
  modulesPath,
  inputs,
  ...
}: {
  imports = [
    ../../profiles/core.nix
    ../../profiles/security.nix
    ../../profiles/network.nix
    ../../profiles/sway
    ../../mixins/greetd.nix
    ../../mixins/esammy.nix
    ../../mixins/gfx-nvidia.nix
    ../../mixins/gnupg.nix
    ../../mixins/easyeffects.nix
    ../../mixins/spotify.nix
    ../../profiles/graphical.nix
    ../../mixins/pipewire.nix
  ];
  config = {
    networking = {
      hostName = "lilith";
    };
    programs.dconf.enable = true;
    home-manager.users.sam = {pkgs, ...} @ hm: {
      wayland.windowManager.sway.config.output."DP-1".resolution = "1920x1080@166Hz";
      programs.ssh = {
        enable = true;
        matchBlocks.jascha = {
          hostname = "doorcraft.de";
          port = 44303;
        };
        matchBlocks.dm4.hostname = "balls.dm4uz3.pt";
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
      programs.git = {
        userName = "samhza";
        userEmail = "sam@samhza.com";
        enable = true;
      };

      home.stateVersion = "22.05";
      nixpkgs.config = {allowUnfree = true;};
      xdg.configFile."nixpkgs/config.nix".text = "{ allowUnfree = true; }";
      programs.alacritty.enable = true;
      programs.password-store = {
        enable = true;
        package = pkgs.pass.withExtensions (exts: [exts.pass-otp]);
        settings.PASSWORD_STORE_DIR = "$HOME/secrets/password-store";
      };
      programs.browserpass = {
        enable = true;
        browsers = ["chrome"];
      };
      programs.nix-index = {
        enable = true;
        enableFishIntegration = true;
      };
      programs.fish = {
        enable = true;
        shellAliases = {
          gc = "git clone";
          l = "ls -alh";
          update-flake = "sudo nixos-rebuild switch --flake /flake";
        };
      };
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
      home.packages = with pkgs; [
        fd
        gdu
        ripgrep
        xdg-utils
        nano
        wget
        curl
        jq
        jo
        openssh
        file
        rsync
        rclone
        yt-dlp
        (pkgs.writeShellApplication {
          name = "discord";
          text = "${pkgs.discord}/bin/discord --use-gl=desktop";
        })
        (pkgs.makeDesktopItem {
          name = "discord";
          exec = "discord";
          desktopName = "Discord";
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
    age.secrets."wireguard-key-lilith".file = ../../secrets/wireguard-key-lilith.age;
    networking.wireguard.interfaces.wg0 = {
      ips = ["10.0.0.2/32"];
      privateKeyFile = config.age.secrets."wireguard-key-lilith".path;
      peers = [
        {
          persistentKeepalive = 25;
          publicKey = "cEBm7V0tVnPJ4GYbOh/vaH4lZ4Km3XpfHzpm0vySim8=";
          endpoint = "samhza.com:51820";
          allowedIPs = ["10.0.0.1/32"];
        }
      ];
    };

    time.timeZone = "America/New_York";

    i18n.defaultLocale = "en_US.UTF-8";

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

    swapDevices = [{device = "/dev/disk/by-uuid/72b6d1c6-eb62-492a-99f1-b29850061a00";}];

    hardware.enableRedistributableFirmware = true;
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    hardware.video.hidpi.enable = lib.mkDefault true;

    system.stateVersion = "22.05";
  };
}
