{
  pkgs,
  lib,
  ...
}: let
  user = "sam";
  patchedSway = pkgs.callPackage ../pkgs/sway.nix {};
  users.users.greeter.packages = [patchedSway];
  greetd = "${pkgs.greetd.greetd}/bin/greetd";
in {
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        inherit user;
        command = "sway --unsupported-gpu";
      };
      default_session = initial_session;
    };
  };
}
