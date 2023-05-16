{
  pkgs,
  lib,
  ...
}: let
  user = "sam";
  patchedSway = pkgs.sway;
  users.users.greeter.packages = [patchedSway pkgs.apple-cursor];
  swayConfig = pkgs.writeText "greetd-sway-config" ''
    seat "*" {
      xcursor_theme macOS-BigSur-White 26
    }
    exec dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK
    exec "${pkgs.greetd.gtkgreet}/bin/gtkgreet -l -s ${pkgs.gnome.gnome-themes-extra}/share/themes/Adwaita-dark/gtk-3.0/gtk.css; swaymsg exit"
    bindsym Mod4+shift+e exec swaynag \
      -t warning \
      -m 'What do you want to do?' \
      -b 'Poweroff' 'systemctl poweroff' \
      -b 'Reboot' 'systemctl reboot'
  '';
in {
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        inherit user;
        command = "sway";
      };
      default_session = {
        command = "env GTK_THEME=Adwaita-dark ${pkgs.sway}/bin/sway --config ${swayConfig}";
      };
    };
  };
  environment.etc."greetd/environments".text = ''
    sway
  '';
}
