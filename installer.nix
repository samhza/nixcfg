
{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"

    ./profiles/core.nix
    ./profiles/interactive.nix
    ./mixins/kanata.nix
  ];

  config = {
    ## <tailscale auto-login-qr>
    services.tailscale.enable = true;
    environment.loginShellInit = ''
      [[ "$(tty)" == "/dev/tty1" || "$(tty)" == "/dev/ttyS0" ]] && (
        echo "trying to connect to tailscale" &>2
        sudo tailscale login --qr
      )
    '';
    ## </tailscale auto-login-qr>

    environment.systemPackages = [
      pkgs.sbctl
    ];

    system.stateVersion = "23.11";
    services.getty.autologinUser = lib.mkForce "sam";

    boot.swraid.enable = lib.mkForce false;

    nixpkgs.hostPlatform.system = "x86_64-linux";
    networking.hostName = "installer";

    boot.loader.timeout = lib.mkOverride 10 10;
    documentation.enable = lib.mkOverride 10 false;
    documentation.info.enable = lib.mkOverride 10 false;
    documentation.man.enable = lib.mkOverride 10 false;
    documentation.nixos.enable = lib.mkOverride 10 false;

    services.fwupd.enable = lib.mkForce false;

    boot.initrd.systemd.enable = lib.mkForce false;
    boot.supportedFilesystems = [ "bcachefs" ];

    nixpkgs.overlays = [(final: super: {
      zfs = super.zfs.overrideAttrs(_: {
        meta.platforms = [];
      });
    })];
    system.disableInstallerTools = lib.mkOverride 10 false;

    systemd.services.sshd.wantedBy = pkgs.lib.mkOverride 10 [ "multi-user.target" ];
  };
}





