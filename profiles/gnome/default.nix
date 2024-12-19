{
  pkgs,
  ...
}: {
  config = {
    xdg.portal.enable = true;
    # xdg.portal.extraPortals = with pkgs;
    # [
    #   xdg-desktop-portal-gtk
    # ];
    # xdg.portal.config = {
    #   common = {
    #     default = [ "gtk" ];
    #   };
    # };

    services.xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
    };
    environment.systemPackages = [
      pkgs.adwaita-icon-theme
    ];
    environment.gnome.excludePackages = (with pkgs; [
      gnome-photos
      gedit # text editor
      gnome-tour
      epiphany # web browser
      geary # email reader
      gnome-characters
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
    ]);
    home-manager.users.sam = { pkgs, config, ...}: {
      home.packages = with pkgs; [
        kitty
        wf-recorder
        pamixer
        pavucontrol
        playerctl
        font-awesome
      ];
      home.sessionVariables = {
        "NIXOS_OZONE_WL" = "1";
      };
    };
  };
}
