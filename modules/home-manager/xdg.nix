{ pkgs, ... }: {

  xdg = {
    enable = true;
    mime.enable = true;
    mimeApps.enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
    portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
      configPackages = [ pkgs.hyprland ];
    };
  };
}
