{
  pkgs,
  lib,
  ...
}: let
  user = "sam";
  patchedSway = pkgs.callPackage ../pkgs/sway.nix {};
  users.users.greeter.packages = [pkgs.callPackage ../pkgs/sway.nix];
  greetd = "${pkgs.greetd.greetd}/bin/greetd";
  gtkgreet = "${pkgs.greetd.gtkgreet}/bin/gtkgreet";

  sway-kiosk = command: "${patchedSway}/bin/sway --unsupported-gpu --config ${pkgs.writeText "kiosk.config" ''
    output * bg #000000 solid_color
    exec "${command}; ${patchedSway}/bin/swaymsg exit"
  ''}";
in {
  environment.etc."greetd/environments".text =
    "${patchedSway}/bin/sway --unsupported-gpu\n"
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
        command = "sh -c ${patchedSway}/bin/sway --unsupported-gpu";
      };
    };
  };
}
