{
  lib,
  config,
  ...
}: {
  options.myConfig.desktop.enable = lib.mkEnableOption "desktop environment (Waybar, Hyprpaper, notifications)";

  config = lib.mkIf config.myConfig.desktop.enable {
    # portal/gsettings dark-mode signal for apps that pick light/dark by prefers-color-scheme
    dconf.settings."org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "WhiteSur-Dark";
    };

    # wallpaper collection symlink
    home.file."Pictures/wallpapers" = {
      source = ../../assets/wallpapers;
    };

    # wallpaper setup
    services.hyprpaper = {
      enable = true;
      settings = {
        splash = false;
        wallpaper = [
          {
            monitor = "";
            path = "${config.stylix.image}";
          }
        ];
      };
    };

    # password prompt setup
    services.hyprpolkitagent.enable = true;

    # sway-nc handles notifications plus the volume/brightness/bluetooth control center
    services.swaync = {
      enable = true;
      settings = {
        positionX = "right";
        positionY = "top";
        control-center-width = 400;
        widgets = [
          "title"
          "dnd"
          "buttons-grid"
          "volume"
          "backlight"
          "mpris"
          "notifications"
        ];
        widget-config = {
          title = {
            text = "Notifications";
            clear-all-button = true;
            button-text = "Clear";
          };
          dnd.text = "Do not disturb";
          volume = {
            label = "󰕾";
            show-per-app = true;
          };
          backlight = {
            label = "󰃠";
            device = "intel_backlight";
          };
          buttons-grid = {
            actions = [
              {
                label = "󰂯";
                command = "blueman-manager";
              }
              {
                label = "󰤨";
                command = "vicinae toggle";
              }
              {
                label = "󰐥";
                command = "wlogout";
              }
            ];
          };
          notifications.vexpand = true;
        };
      };
    };
  };
}
