{
  config,
  lib,
  pkgs,
  ...
}: {
  config.services.dbus.packages = [pkgs.gcr];
  config.home-manager.users.sam = {
    home.packages = with pkgs; [
      gnupg
      pinentry.gnome3
    ];

    home.extraProfileCommands = ''
      export GPG_TTY=$(tty)
      if [[ -n "$SSH_CONNECTION" ]] ;then
        export PINENTRY_USER_DATA="USE_CURSES=1"
      fi
    '';
    programs.gpg.enable = true;
    services.gpg-agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry.gnome3;
      defaultCacheTtl = 3600;
      defaultCacheTtlSsh = 3600;
      maxCacheTtl = 7200;
      enableExtraSocket = true;
      #enableSshSupport = true;
      extraConfig = ''
        allow-preset-passphrase
        no-allow-external-cache
      '';
      verbose = true;
    };
  };
}
