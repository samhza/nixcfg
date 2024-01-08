{
  config,
  lib,
  pkgs,
  modulesPath,
  buildGoModule,
  inputs,
  ...
}:
let
  # govanity = 
  #   pkgs.runCommand "govanity"
  #     {
  #       src = ./govanity.go;
  #       buildInputs = [ pkgs.go ];
  #     } ''
  #     export HOME=$(mktemp -d)
  #     mkdir govanity
  #     cp $src govanity
  #     go build -o $out ./govanity
  #   '';
  # esammy =
  #   pkgs.callPackage
  #   (
  #     {
  #       buildGoModule,
  #       fetchgit,
  #     }:
  #       buildGoModule rec {
  #         name = "esammy";
  #         src = inputs.esammy;

  #         vendorHash = "sha256-yZPxfrht2XPABI0CfRv62Ji0FVfFrTIIbLI3nbiFnws=";
  #         meta = with lib; {
  #           description = "discord meme bot";
  #           homepage = "https://github.com/samhza/esammy";
  #           license = licenses.isc;
  #         };
  #       }
  #   ) {};
  govanity = pkgs.callPackage ({ buildGoPackage }: buildGoPackage rec {
    name = "govanity";
    goPackagePath = name;
    src = lib.fileset.toSource {
      root = ./.;
      fileset = ./govanity.go;
    };
  } ) {};
in
{
  imports = [ 
    ../../profiles/network.nix
    ../../profiles/interactive.nix
    ../../mixins/tailscale.nix
    ../../mixins/esammy.nix
    ../../mixins/musicbot.nix
    (modulesPath + "/profiles/qemu-guest.nix")
  ];
  config = {
    networking.firewall = {
      allowedTCPPorts = [ 80 443 1935 2022 ];
    };
    services.eternal-terminal.enable = true;
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

    systemd.services.govanity = {
      description = "go vanity url";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        DynamicUser = true;
        ExecStart = ''${govanity}/bin/govanity \
          -addr :8082 \
          -base-url samhza.com \
          -import-url 'git https://github.com/samhza'
        '';
      };
    };

    # required for passforios
    # https://github.com/mssun/passforios/issues/624
    services.openssh.settings.Macs = [
      "hmac-sha2-512"
      "hmac-sha2-256"
      "umac-128@openssh.com"
    ];
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
          locations."/" = {
            extraConfig = ''
                if ($args ~* "go-get=1") {
                    proxy_pass http://127.0.0.1:8082;
                }            
            '';
          };
          locations."/u/".root = "/var/www";
          locations."/r/place".root = "/var/www";
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
                    allow publish 173.2.161.197;
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
