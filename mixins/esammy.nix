{
  config,
  pkgs,
  lib,
  inputs,
  ...
}: let
  esammy =
    pkgs.callPackage
    (
      {
        buildGoModule,
        fetchgit,
      }:
        buildGoModule rec {
          name = "esammy";
          src = inputs.esammy;

          vendorHash = "sha256-AOg02xczMnukoHCUgJLxYchRkg6mN+zCIgaV/BfkJpM=";
          meta = with lib; {
            description = "discord meme bot";
            homepage = "https://github.com/samhza/esammy";
            license = licenses.isc;
          };
        }
    ) {};
in {
  age.secrets."esammy.toml".file = ../secrets/esammy.toml.age;
  systemd.services.esammy = {
    description = "discord meme bot";
    after = ["network-online.target" "fs.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "simple";
      DynamicUser = true;
      Environment = ["PATH=${pkgs.ffmpeg-full}/bin:$PATH"];
      LoadCredential = "esammy.toml:${config.age.secrets."esammy.toml".path}";
      ExecStart = "${esammy}/bin/esammy -config %d/esammy.toml";
    };
  };
}
