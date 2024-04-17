
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
    };
    services.xserver.windowManager.fvwm3.enable = true;
    services.xserver.displayManager.autoLogin.user = "sam";
  };
}
