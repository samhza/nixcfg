{
  pkgs,
  lib,
  ...
}: let
  user = "sam";

  users.users.greeter.packages = [pkgs.sway];
  greetd = "${pkgs.greetd.greetd}/bin/greetd";
  gtkgreet = "${pkgs.greetd.gtkgreet}/bin/gtkgreet";

  sway-kiosk = command: "${pkgs.sway}/bin/sway --unsupported-gpu --config ${pkgs.writeText "kiosk.config" ''
    output * bg #000000 solid_color
    exec "${command}; ${pkgs.sway}/bin/swaymsg exit"
  ''}";
in {
  environment.etc."greetd/environments".text =
    "sway\n"
    + "$SHELL -l\n";

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        inherit user;
        command = sway-kiosk "${gtkgreet} -l &>/dev/null";
      };
      initial_session = {
        inherit user;
        command = "sh -c sway";
      };
    };
  };
}
