{
  config,
  lib,
  pkgs,
  modulesPath,
  inputs,
  ...
}:
{
  imports = [ 
    ../../profiles/network.nix
    ../../profiles/interactive.nix
    ../../mixins/tailscale.nix
    (modulesPath + "/profiles/qemu-guest.nix")
  ];
  config = {
    virtualisation.docker.enable = true;
    users.users.sam.extraGroups = [ "docker" ];
    networking.firewall = {
      allowedTCPPorts = [ 80 443 1935 2022 25565 25566 ];
    };
    services.eternal-terminal.enable = true;

    age.secrets."cloudflare-samhza-com-creds" = {
      file = ../../secrets/cloudflare-samhza-com-creds.age;
      owner = "acme";
      group = "acme";
    };
    security.acme = {
      acceptTerms = true;
      defaults.email = "sam@samhza.com";
      certs."bardiel.samhza.com" = {
        dnsProvider = "cloudflare";
        credentialsFile = config.age.secrets."cloudflare-samhza-com-creds".path;
        extraDomainNames = [ "*.bardiel.samhza.com" ];
      };
    };

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/49902d45-717c-4a90-8464-d718684f8f9d";
        fsType = "ext4";
      };
  
    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/12CE-A600";
        fsType = "vfat";
        options = [ "fmask=0022" "dmask=0022" ];
      };
    networking.useDHCP = lib.mkDefault true;
    boot.cleanTmpDir = true;
    zramSwap.enable = true;
    networking.hostName = "bardiel";
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.initrd.availableKernelModules = [ "xhci_pci" "virtio_scsi" ];
    boot.initrd.kernelModules = [ "nvme" ];
    system.stateVersion = "24.05";
  };
}
