{
  config,
  pkgs,
  lib,
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
          src = pkgs.fetchFromGitHub {
            owner = "samhza";
            repo = "esammy";
            rev = "04823d1805e386e79a9a11334c5154ddd26cef7b";
            sha256 = "sha256-sUJSkpmkfQ6v7dI6ASpNZGq6oObFXQTL23qa1G59GjQ=";
          };

          vendorSha256 = "sha256-AOg02xczMnukoHCUgJLxYchRkg6mN+zCIgaV/BfkJpM=";
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
