{
  pkgs,
  lib,
  ...
}: let
  user = "sam";
  #patchedSway = pkgs.callPackage ../pkgs/sway.nix {};
  patchedSway = pkgs.sway;
  users.users.greeter.packages = [patchedSway];
  # users.users.greeter.packages = [pkgs.sway];
  greetd = "${pkgs.greetd.greetd}/bin/greetd";
in {
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        inherit user;
        command = "sway";
      };
      default_session = initial_session;
    };
  };
}
