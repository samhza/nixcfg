{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  config = {
    users.mutableUsers = false;
    environment.defaultPackages = lib.mkForce [];
    programs.fish.enable = true;
    users.users.sam = {
      isNormalUser = true;
      description = "Me";
      extraGroups = ["wheel" "libvirtd" "qemu-libvirtd"];
      packages = [pkgs.git];
      shell = pkgs.fish;
      hashedPassword = "$6$QQi9EyY4ZOXo3zvI$lQmc0LT/yRBlwidDU2Hp1TWJBMYWSGbBlyKFDABK5LdQtGE62IA2mx7UuQVkZSSGijeGMnfN6K1CFzDHxnUHP1";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJHuLxp26yYiaPIz07V4X7a9N+PinBUGsnnVutZSpFaL"
      ];
    };
  };
}
