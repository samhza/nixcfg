{
  config,
  lib,
  pkgs,
  modulesPath,
  inputs,
  ...
}: {
  imports = [ 
    ../../profiles/network.nix
    ../../profiles/interactive.nix
    ../../mixins/tailscale.nix
    ../../mixins/esammy.nix
    (modulesPath + "/profiles/qemu-guest.nix")
  ];
  config = {
    networking.firewall = {
      allowedTCPPorts = [ 80 443 ];
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
    services.nginx = {
      enable = true;
      virtualHosts."samhza.com" = {
          useACMEHost = "samhza.com";
          forceSSL = true;
          root = inputs.site.outputs.packages.${pkgs.system}.static;
          locations."= /" = {
            return = "200 '<pre>email: sam@samhza.com'";
            extraConfig = ''
              add_header Content-Type text/html;
            '';
          };
          locations."/u/".root = "/var/www";
      };
      virtualHosts."goresh.it" = {
          useACMEHost = "goresh.it";
          forceSSL = true;
          locations."= /" = {
            return = "302 https://www.youtube.com/watch?v=ag-2yq6Puxs";
          };
      };
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
