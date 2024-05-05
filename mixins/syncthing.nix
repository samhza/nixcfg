
{ config, pkgs, inputs, ... }:
let
  hostnameDomain = "syncthing.${config.networking.hostName}.${config.networking.domain}";
in
{
  config = {
    networking.firewall.allowedTCPPorts = [ 22000 ];
    networking.firewall.allowedUDPPorts = [ 22000 21027 ];

    networking.firewall.interfaces."tailscale0".allowedTCPPorts = [ 8384 ];

    services.syncthing = {
      enable = true;
      openDefaultPorts = true;
      user = "sam";
      group = "users";
      configDir = "/home/sam/.config/syncthing";
      guiAddress = "0.0.0.0:8384";
    };

    services.nginx.virtualHosts."${hostnameDomain}" = {
      useACMEHost = "${config.networking.hostName}.${config.networking.domain}";
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:8384/";
        proxyWebsockets = true;
      };
    };
  };
}
