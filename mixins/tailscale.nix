{ pkgs, config, lib, ... }:

{
  config = {
    services.tailscale.enable = true;
    networking.firewall.trustedInterfaces = [ "tailscale0" ];
    # networking.nameservers = [ "100.100.100.100" ];
    # networking.search = [ "hare-delta.ts.net" ];
  };
}
