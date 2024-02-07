
{
  config,
  pkgs,
  lib,
  ...
}:
{
  config = {
    services.xserver.enable = true;
    services.xserver.displayManager.sddm = {
      enable = true;
      settings.General.DisplayServer = "Wayland";
    };
    services.xserver.displayManager.defaultSession = "plasmawayland";
    services.xserver.displayManager.autoLogin.user = "sam";
    services.xserver.desktopManager.plasma5.enable = true;
    home-manager.users.sam = { pkgs, config, ...}@hm: {
      home.sessionVariables = {
        "NIXOS_OZONE_WL" = "1";
      };
      home.packages = [
        pkgs.whitesur-icon-theme
      ];
    };
  };
}
