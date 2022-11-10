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
    home-manager.users.sam = {...}: {
      programs.mpv = {
        enable = true;
        config = {
          hwdec = "auto";
          vo = "wlshm";
        };
      };
      home.packages = with pkgs; [
        iosevka
        wl-clipboard
        gnome3.adwaita-icon-theme
        noto-fonts
        noto-fonts-emoji
        noto-fonts-cjk
      ];
      gtk = {
        theme.package = pkgs.gnome.gnome-themes-extra;
        theme.name = "Adwaita-dark";
        enable = true;
        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
          gtk-xft-hinting = 1;
          gtk-xft-hintstyle = "slight";
          gtk-xft-antialias = 1; # => font-antialiasing="grayscale"
          gtk-xft-rgba = "rgb"; # => font-rgb-order="rgb"
        };
      };
      programs.foot = {
        enable = true;
        settings = {
          main = {
            term = "xterm-256color";
            font = "Iosevka:size=12";
            dpi-aware = "yes";
          };
        };
      };
    };
  };
}
