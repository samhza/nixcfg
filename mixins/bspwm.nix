{
  lib,
  config,
  options,
  pkgs,
  ...
}: let
  inherit (builtins) readFile;
in {
   home-manager.users.sam.xsession.bspawm = {pkgs, ...} @ hm: {
    enable = true;
    configFile = ./bspwmrc;
    sxhkd.configFile = ./sxhkdrc;
  };
  environment.systemPackages = with pkgs; [
    (pkgs.alacritty.overrideAttrs (oa: {
      postPatch =
        oa.postPatch
        + ''
          sed -i '/with_vsync/d' alacritty/src/window.rs
        '';
    }))
    maim
    rofi
  ];
}
