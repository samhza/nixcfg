{
  config,
  lib,
  pkgs,
  ...
}: {
  config.home-manager.users.sam = {
    services.easyeffects = {
      enable = true;
      preset = "default";
    };
  };
}
