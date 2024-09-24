{ config, lib, pkgs, inputs, ... }:

{
  config = {
    home-manager.users.sam = { pkgs, ... }@hm: {
      gtk = {
        enable = false;
        # font = prefs.gtk.font;
        # theme = prefs.gtk.theme;
        theme = { name = "Arc-Dark"; package = pkgs.arc-theme; };
        # iconTheme = prefs.gtk.iconTheme;
        cursorTheme = {name = "macOS-BigSur-White"; package = pkgs.apple_cursor;};
        gtk2.configLocation = "${hm.config.xdg.configHome}/gtk-2.0/gtkrc";
        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
          gtk-cursor-theme-size = 28;
          gtk-xft-hinting = 1;
          gtk-xft-hintstyle = "slight";
          gtk-xft-antialias = 1; # => font-antialiasing="grayscale"
          gtk-xft-rgba = "rgb"; # => font-rgb-order="rgb"
        };
        gtk4.extraConfig = {
          Settings = ''
            gtk-application-prefer-dark-theme=1
          '';
        };
      };
    };
  };
}
