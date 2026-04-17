{ lib, config, ... }: {
  options.myConfig.desktop.enable = lib.mkEnableOption "desktop environment (Waybar, Hyprpaper, notifications)";

  config = lib.mkIf config.myConfig.desktop.enable {
    # Waybar setup
    programs.waybar = {
      enable = true;
      systemd.enable = true;
    };

    # wallpaper collection symlink
    home.file."Pictures/wallpapers" = {
      source = ../../assets/wallpapers;
    };

    # wallpaper setup
    services.hyprpaper = {
      enable = true;
      settings = {
        preload = [ "${config.stylix.image}" ];
        wallpaper = [ ",${config.stylix.image}" ];
      };
    };

    # password prompt setup
    services.hyprpolkitagent.enable = true;

    # enable sway-nc for notifications
    services.swaync.enable = true;
  };
}
