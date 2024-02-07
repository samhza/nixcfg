{
  config,
  pkgs,
  buildGoModule,
  inputs,
  ...
}:
let
  govanity = pkgs.callPackage (
    {
      buildGoModule,
    }:
      buildGoModule rec {
        name = "govanity";
        src = inputs.govanity;
        vendorHash = "sha256-/v+xBgpWiorXFXP5rTgJLWTbRLb/LDS70s6+lhtYdo0=";
      }
  ) {};
  govanityCfg = (pkgs.formats.toml { }).generate "govanity.toml" {
    Base = "samhza.com";
    SocketPath = "/run/govanity/govanity.sock";
    SocketPerm = "0777";
    Modules = {
      "discord/router" = "git https://github.com/samhza/discordrouter.git";
      "ffmpeg" = "git https://github.com/samhza/go-ffmpeg.git";
    };
  };
in {
  systemd.services.govanity = {
    description = "go vanity url";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      DynamicUser = true;
      RuntimeDirectory = "govanity";
      ExecStart = "${govanity}/bin/govanity -config ${govanityCfg}";
    };
  };
}
