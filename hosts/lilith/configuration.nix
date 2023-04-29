{
  config,
  lib,
  pkgs,
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
    ../../mixins/helix.nix
    ../../mixins/gfx-nvidia.nix
    ../../mixins/gnupg.nix
    ../../mixins/easyeffects.nix
    ../../mixins/spotify.nix
    ../../mixins/pipewire.nix
    ../../mixins/tailscale.nix
    ../../mixins/libvirt.nix
    ../../mixins/libvirtd.nix

    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];
  config = {
    services.transmission = {
      enable = true;
      group = "media";
      settings = {
        download-dir = "/4tb/bt/done";
        incomplete-dir = "/4tb/bt/partial";
      };
    };
    users.groups.media.members = [ "sam" "transmission" ];
    services.mullvad-vpn.enable = true;
    networking = {
      hostName = "lilith";
    };
    networking.firewall = {
      allowedTCPPorts = [ 2234 ];
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
      wayland.windowManager.sway.config.output."DP-2" = {
        resolution = "1920x1080@166Hz";
        position = "1280,0";
      };
      wayland.windowManager.sway.config.output."HEADLESS-1" = {
        resolution = "1280x720@30Hz";
        position = "0,900";
        bg = "#000000 solid_color";
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
        browsers = ["chrome" "vivaldi"];
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
        pavucontrol
        foliate
        nicotine-plus
        lollypop
        entr
        nodejs
        python3
        alacritty
        gnomeExtensions.dash-to-panel
        jujutsu
        git-branchless
        go
        gopls
        gotools
        rnix-lsp
        delve
        gcc
        gimp
        gdu
        vivaldi
        vivaldi-ffmpeg-codecs
        rustup
        imv
        openssl
        pkgconfig
        pkg-config
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
        vscode
        (pkgs.callPackage ./cgif.nix {})
        (pkgs.vips.overrideAttrs (old: {
          nativeBuildInputs = old.nativeBuildInputs ++ [(pkgs.callPackage ./cgif.nix {})];
        }))
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
    boot.loader.systemd-boot.consoleMode = "max";
    console.keyMap = "${pkgs.colemak-dh}/share/keymaps/i386/colemak/colemak_dh_ansi_us.map";

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

    system.stateVersion = "22.11";
  };
}
