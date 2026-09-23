{
  config,
  lib,
  pkgs,
  ...
}: let
  c = config.lib.stylix.colors.withHashtag;
  font = config.stylix.fonts.monospace.name;
  icons = "${pkgs.wlogout}/share/wlogout/icons";
in {
  config = lib.mkIf config.myConfig.desktop.enable {
    programs.wlogout = {
      enable = true;

      layout = [
        {
          label = "lock";
          action = "pidof hyprlock || hyprlock";
          text = "Lock";
          keybind = "l";
        }
        {
          label = "suspend";
          action = "systemctl suspend";
          text = "Suspend";
          keybind = "s";
        }
        {
          label = "hibernate";
          action = "systemctl hibernate";
          text = "Hibernate";
          keybind = "h";
        }
        {
          label = "reboot";
          action = "systemctl reboot";
          text = "Reboot";
          keybind = "r";
        }
        {
          label = "shutdown";
          action = "systemctl poweroff";
          text = "Shutdown";
          keybind = "p";
        }
      ];

      style = ''
        * {
          font-family: "${font}";
          font-size: 15px;
          background-image: none;
          transition: 20ms;
        }

        window {
          background-color: ${c.base00}e6;
        }

        button {
          color: ${c.base05};
          background-color: ${c.base01};
          border: 2px solid ${c.base02};
          border-radius: 14px;
          margin: 8px;
          background-repeat: no-repeat;
          background-position: center;
          background-size: 22%;
        }

        button:focus,
        button:hover {
          background-color: ${c.base02};
          border-color: ${c.base0D};
          color: ${c.base05};
        }

        #lock { background-image: image(url("${icons}/lock.png")); }
        #suspend { background-image: image(url("${icons}/suspend.png")); }
        #hibernate { background-image: image(url("${icons}/hibernate.png")); }
        #reboot { background-image: image(url("${icons}/reboot.png")); }
        #shutdown { background-image: image(url("${icons}/shutdown.png")); }

        #shutdown:focus,
        #shutdown:hover {
          border-color: ${c.base08};
        }
      '';
    };
  };
}
