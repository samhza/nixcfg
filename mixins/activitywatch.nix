{
  pkgs,
  config,
  ...
}: {
  config = {
    home-manager.users.sam = {pkgs, ...}: {
      services.activitywatch = {
        enable = true;
        package = pkgs.aw-server-rust;
        watchers = { awatcher.package = pkgs.awatcher; };
      };
    };
  };
}
