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
  database = {
    connection_string = "postgres:///dendrite?host=/run/postgresql";
    max_open_conns = 90;
    max_idle_conns = 5;
    conn_max_lifetime = -1;
  };

in
{
  imports = [ 
    ../../profiles/network.nix
    ../../profiles/interactive.nix
    ../../mixins/tailscale.nix
    ../../mixins/esammy.nix
    ../../mixins/govanity.nix
    ../../mixins/musicbot.nix
    ../../mixins/syncthing.nix
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
    security.acme = rec {
      acceptTerms = true;
      defaults.email = "sam@samhza.com";
      certs."samhza.com" = {
        dnsProvider = "cloudflare";
        credentialsFile = config.age.secrets."cloudflare-samhza-com-creds".path;
      };
      certs."matrix.samhza.com" = certs."samhza.com";
      certs."ntfy.samhza.com" = certs."samhza.com";
      certs."ramiel.samhza.com" = {
        #figure out how to use inherit w this
        dnsProvider = "cloudflare";
        credentialsFile = config.age.secrets."cloudflare-samhza-com-creds".path;
        domain = "*.ramiel.samhza.com";
      };
      certs."goresh.it" = certs."samhza.com";
    };
    users.users.nginx.extraGroups = [ "acme" ];
    systemd.services.nginx.preStart = ''
      mkdir -p /tmp/{hls,dash}
    '';

    # required for passforios
    # https://github.com/mssun/passforios/issues/624
    services.openssh.settings.Macs = [
      "hmac-sha2-512"
      "hmac-sha2-256"
      "umac-128@openssh.com"
    ];
    security.pam.enableOTPW = true;

    services.nginx = {
      enable = true;
      virtualHosts."samhza.com" = {
          useACMEHost = "samhza.com";
          forceSSL = true;
          root = inputs.site.outputs.packages.${pkgs.system}.static;
          locations."= /" = {
            return = "404 ''";
          };
          locations."/" = {
            extraConfig = ''
                if ($args ~* "go-get=1") {
                    proxy_pass http://unix:/var/run/govanity/govanity.sock;
                }            
            '';
          };
          locations."/.well-known/matrix/server" = {
            return = "200 '{ \"m.server\": \"matrix.samhza.com:443\" }'";
          };
          locations."/.well-known/matrix/client" = {
            return =  "200 '{\"m.homeserver\":{\"base_url\":\"https://matrix.samhza.com\"}}'";
          };
          locations."/u/".root = "/var/www";
          #locations."/r/place".root = "/var/www";
      };
      virtualHosts."matrix.samhza.com" = {
        useACMEHost = "matrix.samhza.com";
        forceSSL = true;
        locations."/_matrix" = {
          proxyPass = "http://localhost:8008";
        };
        extraConfig = ''
          proxy_set_header Host      $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_read_timeout         600;
        '';
      };
      virtualHosts."ntfy.samhza.com" = {
        useACMEHost = "ntfy.samhza.com";
        forceSSL = true;
        locations."/" = {
          proxyPass = "http://unix:/run/ntfy-sh/ntfy-sh.sock";
        };
      };
      virtualHosts."goresh.it" = {
          useACMEHost = "goresh.it";
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

    services.dendrite = {
      enable = true;
      settings.global = {
        server_name = "samhza.com";
        disable_federation = false;
        private_key = "/$CREDENTIALS_DIRECTORY/matrix_key.pem";
      };
      settings = {
         logging = [
          {
            type = "std";
            level = "warn";
          }
        ];
        app_service_api = {
          inherit database;
          config_files = [ ];
        };
        media_api = {
          inherit database;
          dynamic_thumbnails = true;
        };
        room_server = {
          inherit database;
        };
        push_server = {
          inherit database;
        };
        relay_api = {
          inherit database;
        };
        mscs = {
          inherit database;
          # mscs = [ "msc2836" "msc2946" ];
        };
        sync_api = {
          inherit database;
          real_ip_header = "X-Real-IP";
        };
        key_server = {
          inherit database;
        };
        federation_api = {
          inherit database;
          key_perspectives = [
            {
              server_name = "matrix.org";
              keys = [
                {
                  key_id = "ed25519:auto";
                  public_key = "Noi6WqcDj0QmPxCNQqgezwTlBKrfqehY1u2FyWP9uYw";
                }
                {
                  key_id = "ed25519:a_RXGa";
                  public_key = "l8Hft5qXKn1vfHrg3p4+W8gELQVo8N13JkluMfmn2sQ";
                }
              ];
            }
          ];
          prefer_direct_fetch = false;
        };
        user_api = {
          account_database = database;
          device_database = database;
        };       
      };
    };

    systemd.services.dendrite.serviceConfig.LoadCredential = [
      "matrix_key.pem:/etc/dendrite/matrix_key.pem"
    ];

    systemd.services.dendrite.after = [ "postgresql.service" ];
    services.postgresql = {
      enable = true;
      ensureDatabases = [ "dendrite" ];
      ensureUsers = [
        {
          name = "dendrite";
          ensureDBOwnership = true;
        }
      ];
    };
    services.ntfy-sh = {
      enable = true;
      settings = {
        base-url = "https://ntfy.samhza.com";
        upstream-base-url = "https://ntfy.sh";
        listen-unix = "/var/run/ntfy-sh/ntfy-sh.sock";
        listen-unix-mode = 511;
        auth-default-access = "deny-all";
      };
    };
    systemd.services.ntfy-sh.serviceConfig.RuntimeDirectory = "ntfy-sh";
    
    boot.cleanTmpDir = true;
    zramSwap.enable = true;
    networking.hostName = "ramiel";
    #networking.domain = "";
    boot.loader.grub.device = "/dev/sda";
    boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "xen_blkfront" "vmw_pvscsi" ];
    boot.initrd.kernelModules = [ "nvme" ];
    fileSystems."/" = { device = "/dev/sda1"; fsType = "ext4"; };
    system.stateVersion = "22.11";
  };
}
