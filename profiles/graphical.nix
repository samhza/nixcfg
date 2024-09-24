{
  config,
  pkgs,
  lib,
  ...
}: let
  nvStable = config.boot.kernelPackages.nvidiaPackages.stable;
  nvBeta = config.boot.kernelPackages.nvidiaPackages.beta;
  nvidiaPkg =
    if (lib.versionOlder nvBeta.version nvStable.version)
    then config.boot.kernelPackages.nvidiaPackages.stable
    else config.boot.kernelPackages.nvidiaPackages.beta;
in {
  config = {
    programs.light.enable = true;
    users.groups.video = {};
    home-manager.users.sam = {...}: {
      services.gnome-keyring.enable = true;
      fonts.fontconfig.enable = true;
      programs.mpv = {
        enable = true;
        config = {
          hwdec = "auto";
          vo = "wlshm";
        };
        bindings = {
          "s" = "playlist-prev";
          "t" = "playlist-next";
          "r" = "seek 4";
          "a" = "seek -5";
        };
      };
      home.packages = with pkgs; [
        iosevka-comfy.comfy-fixed
        iosevka-comfy.comfy-duo
        go-font
        powerline-fonts
        wl-clipboard
        gnome3.adwaita-icon-theme
        noto-fonts
        noto-fonts-emoji
        noto-fonts-cjk
        corefonts
      ];
      # gtk = {
      #   theme.package = pkgs.arc-theme;
      #   theme.name = "Arc-dark";
      #   enable = true;
      #   gtk3.extraConfig = {
      #     gtk-application-prefer-dark-theme = 1;
      #     gtk-xft-hinting = 1;
      #     gtk-xft-hintstyle = "slight";
      #     gtk-xft-antialias = 1; # => font-antialiasing="grayscale"
      #     gtk-xft-rgba = "rgb"; # => font-rgb-order="rgb"
      #   };
      #   font = {
      #     package = pkgs.noto-fonts;
      #     name = "Noto Sans 11";
      #   };
      # };
      programs.foot = {
        enable = true;
        settings = {
          main = {
            # term = "xterm-256color";
          };
          key-bindings = {
            prompt-next = "Control+Shift+n";
            prompt-prev = "Control+Shift+p";
            spawn-terminal = "Control+Shift+Return";
            "pipe-command-output" = "[wl-copy] Control+Return";
          };
        };
      };
    };
  };
}
