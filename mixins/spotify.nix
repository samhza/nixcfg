{
  pkgs,
  config,
  ...
}: {
  config = {
    age.secrets."spotify-password" = {
      owner = "sam";
      file = ../secrets/spotify-password.age;
    };
    home-manager.users.sam = {pkgs, ...}: {
      services.spotifyd = {
        enable = true;
        settings.global = {
          device_name = "${config.networking.hostName}-spotifyd";
          username = "samgaming2005";
          password_cmd = "${pkgs.coreutils}/bin/cat ${config.age.secrets."spotify-password".path}";
          autoplay = true;
        };
      };

      home.packages = [
        pkgs.spotify-tui
      ];
    };
  };
}
