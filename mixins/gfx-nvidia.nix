{ config, pkgs, lib, ... }:

let
  nvStable = config.boot.kernelPackages.nvidiaPackages.stable;
  nvBeta = config.boot.kernelPackages.nvidiaPackages.beta;
  # nvidiaPkg = nvStable;
  nvidiaPkg =
    if (lib.versionOlder nvBeta.version nvStable.version)
    then config.boot.kernelPackages.nvidiaPackages.stable
    else config.boot.kernelPackages.nvidiaPackages.beta;
in {
  config = {
    home-manager.users.sam = {pkgs, ...}: {
      wayland.windowManager.sway.extraOptions = ["--unsupported-gpu"];
    };

    environment.sessionVariables = {
      WLR_DRM_NO_ATOMIC = "1";
      WLR_NO_HARDWARE_CURSORS = "1";
      LIBVA_DRIVER_NAME = "nvidia";
      GBM_BACKEND = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      MOZ_DISABLE_RDD_SANDBOX = "1";
      EGL_PLATFORM = "wayland";
    };
    boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_drm" "nvidia_uvm" ];
    hardware = {
      opengl.enable = true;
      opengl.driSupport32Bit = true;
      opengl.extraPackages = [pkgs.nvidia-vaapi-driver];
      nvidia = {
        # open = true;
        modesetting.enable = true;
        nvidiaSettings = false;
        package = nvidiaPkg;
        powerManagement.enable = false;
      };
    };
    services.xserver.videoDrivers = ["nvidia"];
  };
}
