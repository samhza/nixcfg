
{
  config,
  pkgs,
  lib,
  ...
}:
let
	jar = builtins.fetchurl {
		url = "https://github.com/jagrosh/MusicBot/releases/download/0.3.9/JMusicBot-0.3.9.jar";
		sha256 = "03xa17fvz493mr2kr5m6lfw4j0m5n0symk645h3aqcdmcyip43fq";
	};
in
{
  age.secrets."musicbot-config.txt".file = ../secrets/musicbot-config.txt.age;
  systemd.services.musicbot = {
    description = "discord music bot";
    after = ["network-online.target" "fs.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "simple";
      DynamicUser = true;
      StateDirectory = "musicbot";
      WorkingDirectory = "/var/lib/musicbot";
      LoadCredential = "config.txt:${config.age.secrets."musicbot-config.txt".path}";
      ExecStart = "${pkgs.jre}/bin/java -Dnogui=true -Dconfig=%d/config.txt -jar ${jar}";
    };
  };
}
