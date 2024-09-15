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
    ../../mixins/pipewire.nix
    ../../mixins/gtk.nix
    ../../mixins/kanata.nix
    ../../mixins/gnupg.nix
    ../../mixins/helix.nix
    ../../mixins/vscode.nix
    ../../mixins/tailscale.nix
    # ../../mixins/easyeffects.nix
    ../../mixins/libvirtd.nix
    ../../mixins/libvirt.nix
    ../../mixins/syncthing.nix
    ./hardware-configuration.nix

    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-x1-6th-gen
  ];
  config = {
    # networking.networkmanager.wifi.scanRandMacAddress = false;
    # networking.networkmanager.wifi.backend = "iwd";
    documentation.dev.enable = true;
    services.postgresql = {
      enable = true;
      ensureDatabases = ["sam"];
      authentication = pkgs.lib.mkOverride 10 ''
        #type database  DBuser  auth-method
        local all       all     trust
      '';
    };
    virtualisation.docker.enable = true;
    users.users.sam.extraGroups = [ "docker" ];
    networking = {
      hostName = "leliel";
    };
    services.tlp = {
      enable = true;
      settings = {
        START_CHARGE_THRESH_BAT0=50;
        STOP_CHARGE_THRESH_BAT0=75;
      };
    };
    virtualisation.libvirtd.enable = true;
    services.power-profiles-daemon.enable = false;
    services.kanata.keyboards.colemak.devices = [ "/dev/input/by-path/platform-i8042-serio-0-event-kbd" ]; #"/dev/input/by-path/pci-0000:00:1f.4-serio-2-event-mouse" ];
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
    services.gpm.enable = true;
    programs.sway.enable = true;
    programs.dconf.enable = true;
    programs.steam = {
      enable = true;
      extraCompatPackages = [
        pkgs.proton-ge-bin
      ];
    };
    systemd.sleep.extraConfig = "HibernateDelaySec=1h";
    services.logind.lidSwitch = "suspend-then-hibernate";
    services.logind.lidSwitchDocked = "ignore";
    services.tumbler.enable = true;

    programs.command-not-found.enable = false;
    programs.nix-index = {
      enable = true;
      enableFishIntegration = true;
    };

    home-manager.users.sam = {pkgs, ...}: {
      programs.mbsync.enable = true;
      programs.msmtp.enable = true;
      programs.notmuch = {
          enable = true;
          hooks.preNew = "${pkgs.notmuch-mailmover}/bin/notmuch-mailmover";
      };
      programs.notmuch.search.excludeTags = [ "trash" "spam" ];
      programs.lieer.enable = true;
      services.lieer.enable = true;
      services.mbsync.enable = true;
      services.mbsync.preExec = "${pkgs.notmuch-mailmover}/bin/notmuch-mailmover";
      services.mbsync.postExec = "${pkgs.notmuch}/bin/notmuch new";
      services.imapnotify.enable = true;
      systemd.user.services.imapnotify.Service.Environment = [
        "PASSWORD_STORE_DIR=$HOME/secrets/password-store"
      ];
      accounts.email.maildirBasePath = "Mail";
      accounts.email.accounts.samhza = {
        folders.inbox = "";
        notmuch.enable = true;
        address = "sam@samhza.com";
        userName = "sam@samhza.com";
        imap.host = "imap.migadu.com";
        smtp.host = "smtp.migadu.com";
        primary = true;
        mbsync = {
          enable = true;
          create = "maildir";
          subFolders = "Maildir++";
        };
        imapnotify = {
          enable = true;
          boxes = [ "INBOX" ];
          onNotify = "${pkgs.isync}/bin/mbsync samhza";
          onNotifyPost = "${pkgs.notmuch}/bin/notmuch new && ${pkgs.libnotify}/bin/notify-send 'New mail arrived'";
        };
        msmtp.enable = true;
        realName = "Samuel Hernandez";
        passwordCommand = "${pkgs.coreutils}/bin/env PASSWORD_STORE_DIR=/home/sam/secrets/password-store ${pkgs.pass}/bin/pass show email";
      };
      accounts.email.accounts.rutgers = {
        folders.inbox = "";
        notmuch.enable = true;
        flavor = "gmail.com";
        address = "samuel.hernandez9@rutgers.edu";
        userName = "sh1758@scarletmail.rutgers.edu";
        imap.host = "imap.gmail.com";
        smtp.host = "smtp.gmail.com";
        lieer = {
          enable = true;
          sync.enable = true;
          settings.account = "sh1758@scarletmail.rutgers.edu";
        };
        imapnotify = {
          enable = true;
          boxes = [ "INBOX" ];
          onNotify = "${pkgs.lieer}/bin/gmi sync -C ~/Mail/rutgers";
          onNotifyPost = "${pkgs.notmuch}/bin/notmuch new && ${pkgs.libnotify}/bin/notify-send 'New mail arrived'";
        };
        msmtp.enable = true;
        realName = "Samuel Hernandez";
        passwordCommand = "${pkgs.coreutils}/bin/env PASSWORD_STORE_DIR=/home/sam/secrets/password-store ${pkgs.pass}/bin/pass show rutgers-smtp";
      };

      services.kanshi.enable = true;
      services.kanshi.profiles.undocked.outputs = [
      { criteria = "eDP-1";
        mode = "2560x1440@60.012Hz";
        position = "0,0";
        scale = 1.75; }
      ];
      services.kanshi.profiles.docked.outputs = [
      { criteria = "eDP-1";
        status = "enable";
        mode = "2560x1440@60.012Hz";
        position = "2048,512";
        scale = 2.00; }
      { criteria = "HDMI-A-1";
        status = "enable";
        mode = "2560x1440@60Hz";
        position = "0,0";
        scale = 1.25; }
      ];
      /*
      services.kanshi.profiles."0docked".outputs = [
      { criteria = "eDP-1";
        status = "enable";
        mode = "2560x1440@60.012Hz";
        position = "0,1225";
        scale = 1.75; }
      { criteria = "HDMI-A-1";
        status = "enable";
        mode = "2560x1440@60Hz";
        position = "1462,0";
        transform = "90";
        scale = 1.25; }
      ];
      */

      programs.foot.settings = {
        main.font = lib.mkForce "Iosevka Comfy Fixed:size=10";
        # main.font = lib.mkForce "Go Mono:size=10";
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


      nixpkgs.config.permittedInsecurePackages = [
        "electron-25.9.0"
        "electron-28.3.3"
      ];
      home.sessionVariables = {
        EDITOR = "hx";
        SSH_AUTH_SOCK = "/run/user/1000/keyring/ssh";
      };
      wayland.windowManager.sway.config.seat."*".xcursor_theme ="macOS-BigSur-White 26";
      services.wlsunset = {
        latitude = "40.8";
        longitude = "-74.0";
        enable = true;
      };
      home.sessionPath = [ "$HOME/go/bin" "$HOME/.cargo/bin" "$HOME/bin" ];
      home.packages = with pkgs; [
        qbittorrent
        sshpass
        mg
        powertop
        gnutls
        (pkgs.texlive.combine {
          inherit (pkgs.texlive) scheme-basic
            dvisvgm dvipng # for preview and export as html
            mylatexformat preview xcolor # for org-latex-preview-process-precompiled
            wrapfig amsmath ulem hyperref capt-of;

          #(setq org-latex-compiler "lualatex")
          #(setq org-preview-latex-default-process 'dvisvgm)
        })
        racket
        # (vscode-with-extensions.override {
        #   vscodeExtensions = with vscode-extensions; [
        #     continue.continue
        #   ];
        # })
        racket
        llm
        sqlite
        xclip
        maim
        slurp
        picom
        rofi
        clang-tools
        watchman
        scc
        ffmpeg
        (inputs.emacs-overlay.packages."x86_64-linux".emacs-pgtk)
        man-pages
        (pkgs.vis.overrideAttrs (oa: {
          src = fetchFromGitHub {
            owner = "martanne";
            repo = "vis";
            rev = "1fc175627f3afe938be0b5daa6a864b281725fec";
            sha256 = "sha256-dOiQ2SlZuvL+M4I3jF5wLfevlC0/kYYT7979ABDO204=";
          };
        }))
        keepassxc
        pdfgrep
        poppler_utils
        anki
        neovim
        restic
        telegram-desktop
        element-desktop
        nil
        jdt-language-server
        gdb
        xxd
        gcc
        rustup
        file
        moreutils
        libreoffice
        pv
        dislocker
        ntfs3g
        # vial # needed for qmk
        wev
        imv
        gimp
        zip
        strace
      	imagemagick
        #whisper-ctranslate2
        #python311Packages.faster-whisper
        foliate
        delve
        mupdf
        libtiff
        scantailor
        entr
        backblaze-b2
        jujutsu
        aerc
        himalaya
        neverest
        isync
        mblaze
        par
        lynx
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
        appimage-run
        apple-cursor
        # (pkgs.callPackage ../../pkgs/beeper-desktop.nix {} )
        (pkgs.vivaldi.override {
          commandLineArgs = ["--force-dark-mode"];
        })
        vivaldi-ffmpeg-codecs
        xdg-utils
        discord
        # logseq
        # obsidian
        (pkgs.vesktop.overrideAttrs ({postConfigure ? "", ...} : {
          postConfigure = postConfigure + ''
            sed -i '/shiggy.gif/d' ./static/views/splash.html
          '';
        }))
        # (pkgs.logseq.overrideAttrs (oa: {
        #   version = "idfk";
        #   src = inputs.logseq;
        # }))
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
      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
    };
    programs.java.enable = true;
    virtualisation.waydroid.enable = true;
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

    system.stateVersion = "24.05";
  };
}
