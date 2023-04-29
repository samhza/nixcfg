{ config, lib, pkgs, inputs, ... }:

{
  config = {
    home-manager.users.sam = { pkgs, ... }@hm: {
      # home.sessionVariables = {
        # XCURSOR_PATH = prefs.cursor.package.outPath;
      # };
      # home.file.".icons/default/index.theme".text = ''
      #   [icon theme]
      #   [icon theme]
      #   Name=Default
      #   Name=Default
      #   Comment=Default Cursor Theme
      #   Comment=Default Cursor Theme
      #   Inherits=${prefs.cursor.name}
      #   Inherits=${prefs.cursor.name}
      # '';

      gtk = {
        enable = true;
#        font = prefs.gtk.font;
#        theme = prefs.gtk.theme;
#        iconTheme = prefs.gtk.iconTheme;
        cursorTheme = {name = "Vanilla-DMZ"; package = pkgs.vanilla-dmz;};
        gtk2.configLocation = "${hm.config.xdg.configHome}/gtk-2.0/gtkrc";
        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
          gtk-cursor-theme-size = 48;
          gtk-xft-hinting = 1;
          gtk-xft-hintstyle = "slight";
          gtk-xft-antialias = 1; # => font-antialiasing="grayscale"
          gtk-xft-rgba = "rgb"; # => font-rgb-order="rgb"
        };
      };
    };
  };
}
