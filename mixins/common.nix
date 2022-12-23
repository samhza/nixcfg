{ pkgs, lib, config, inputs, ... }:

{
  imports = [
    ../profiles/user.nix
  ];
  config = {
    security = {
      sudo.enable = true;
      sudo.wheelNeedsPassword = false;
      please.enable = true;
      please.wheelNeedsPassword = false;
    };
    i18n.defaultLocale = "en_US.UTF-8";
    time.timeZone = "America/New_York";
    services.getty = {
      greetingLine = ''\l  -  (kernel: \r) (label: ${config.system.nixos.label}) (arch: \m)'';
      helpLine = ''
          Welcome to my DEATH MACHINE, interloper!
      '';
    };
    documentation = {
      enable = false;
      doc.enable = false;
      man.enable = true;
      info.enable = false;
      nixos.enable = false;
    };
  };
}

