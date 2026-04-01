{ ... }: {
  # Waybar setup
  programs.waybar = {
    enable = true;
    systemd.enable = true;
  };

  # wallpaper setup
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ "~/Pictures/wallpaper.jpg" ];
      wallpaper = [ ",~/Pictures/wallpaper.jpg" ];
    };
  };

  # password prompt setup
  services.hyprpolkitagent.enable = true;

  # enable sway-nc for notifications
  services.swaync.enable = true;
}
