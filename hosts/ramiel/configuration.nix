{
  config,
  lib,
  pkgs,
  modulesPath,
  inputs,
  ...
}:
let

in
{
  imports = [ 
    ../../profiles/network.nix
    ../../profiles/interactive.nix
    ../../mixins/tailscale.nix
    ../../mixins/esammy.nix
    (modulesPath + "/profiles/qemu-guest.nix")
  ];
  config = {
    networking.firewall = {
      allowedTCPPorts = [ 80 443 1935 ];
    };
    age.secrets."cloudflare-samhza-com-creds" = {
      file = ../../secrets/cloudflare-samhza-com-creds.age;
      owner = "acme";
      group = "acme";
    };
    age.secrets."iwantmyname-creds" = {
      file = ../../secrets/iwantmyname-creds.age;
      owner = "acme";
      group = "acme";
    };
    security.acme = {
      acceptTerms = true;
      defaults.email = "sam@samhza.com";
      certs."samhza.com" = {
        dnsProvider = "cloudflare";
        credentialsFile = config.age.secrets."cloudflare-samhza-com-creds".path;
      };
      certs."goresh.it" = {
        dnsProvider = "iwantmyname";
        credentialsFile = config.age.secrets."iwantmyname-creds".path;
      };
    };
    users.users.nginx.extraGroups = [ "acme" ];
    systemd.services.nginx.preStart = ''
      mkdir -p /tmp/{hls,dash}
    '';
    services.nginx = {
      enable = true;
      virtualHosts."samhza.com" = {
          useACMEHost = "samhza.com";
          forceSSL = true;
          root = inputs.site.outputs.packages.${pkgs.system}.static;
          locations."= /" = {
            return = "200 '<pre>email: sam@samhza.com'";
            extraConfig = ''
               types { } default_type "text/html; charset=utf-8";
            '';
          };
          locations."/u/".root = "/var/www";
      };
      virtualHosts."goresh.it" = {
          useACMEHost = "goresh.it";
          forceSSL = true;
          locations."= /" = {
            return = "302 https://goreshit.bandcamp.com/";
          };
          locations."= /live" = {
            extraConfig = ''
               types { } default_type "text/html; charset=utf-8";
            '';
            alias = ./cheers.html;
          };
          locations."/dash" = {
            extraConfig = ''
              autoindex on;
            '';
            root = "/tmp";
          };
      };
      appendConfig = ''
        rtmp {
            server {
                chunk_size 4096;
                listen 1935; 
                application live {
                    allow publish 127.0.0.1;
                    live on;
                    record off;
                    dash on; 
                    dash_playlist_length 30s;
                    dash_path /tmp/dash;
                }
            } 
        }
      '';
    };

    boot.cleanTmpDir = true;
    zramSwap.enable = true;
    networking.hostName = "ramiel";
    networking.domain = "";
    boot.loader.grub.device = "/dev/sda";
    boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" ];
    boot.initrd.kernelModules = [ "nvme" ];
    fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
    system.stateVersion = "22.11";
  };
}
