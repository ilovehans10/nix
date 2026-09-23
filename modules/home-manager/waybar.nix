{
  config,
  lib,
  pkgs,
  ...
}: let
  c = config.lib.stylix.colors.withHashtag;
  # non-Mono nerd font variant: the Mono one shrinks wide icons into a single cell
  font = lib.removeSuffix " Mono" config.stylix.fonts.monospace.name;
  cfgDir = "${config.xdg.configHome}/waybar";

  modules = {
    "hyprland/workspaces" = {
      format = "{name}";
      on-click = "activate";
      sort-by-number = true;
    };

    clock = {
      format = "{:%H:%M}";
      format-alt = "{:%a %d %b}";
      tooltip-format = "<tt>{calendar}</tt>";
    };

    tray = {
      spacing = 10;
    };

    network = {
      format-wifi = "{icon} {signalStrength}%";
      format-ethernet = "󰈀";
      format-disconnected = "󰤭";
      format-icons = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
      tooltip-format-wifi = "{essid}\n{signalStrength}% · {frequency} GHz\n{ipaddr}";
      tooltip-format-ethernet = "{ifname}\n{ipaddr}";
      tooltip-format-disconnected = "Disconnected";
      on-click = "vicinae toggle";
    };

    pulseaudio = {
      format = "{icon} {volume}%";
      format-muted = "󰝟";
      format-bluetooth = "{icon} {volume}%";
      format-icons = {
        default = ["󰕿" "󰖀" "󰕾"];
        headphone = "󰋋";
      };
      scroll-step = 5;
      on-click = "swaync-client -t -sw";
      on-click-right = "pwvucontrol";
    };

    cpu = {
      format = "󰻠 {usage}%";
      interval = 5;
    };

    backlight = {
      device = "intel_backlight";
      format = "{icon} {percent}%";
      format-icons = ["󰃞" "󰃟" "󰃠"];
      on-click = "swaync-client -t -sw";
      on-scroll-up = "brightnessctl s +5%";
      on-scroll-down = "brightnessctl s 5%-";
    };

    memory = {
      format = "󰍛 {percentage}%";
      tooltip-format = "RAM {used:0.1f}G of {total:0.1f}G ({percentage}%)\nSwap {swapUsed:0.1f}G of {swapTotal:0.1f}G";
      interval = 5;
    };

    # thermal_zone0 is INT3400 and always reads 20C; coretemp is the real CPU sensor
    temperature = {
      hwmon-path-abs = "/sys/devices/platform/coretemp.0/hwmon";
      input-filename = "temp1_input";
      critical-threshold = 85;
      format = "󰔏 {temperatureC}°C";
      interval = 5;
    };

    battery = {
      bat = "BAT0";
      adapter = "AC";
      states = {
        warning = 30;
        critical = 15;
      };
      format = "{icon} {capacity}%";
      format-charging = "󰂄 {capacity}%";
      format-plugged = "󰂄 {capacity}%";
      format-icons = ["󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹"];
      tooltip-format = "{capacity}% · {timeTo}";
    };

    "custom/power" = {
      format = "󰐥";
      tooltip = false;
      on-click = "wlogout";
    };
  };

  bar = modulesRight:
    modules
    // {
      layer = "top";
      position = "top";
      spacing = 4;
      modules-left = ["clock"];
      modules-center = ["hyprland/workspaces"];
      modules-right = modulesRight;
    };

  fullRight = [
    "network"
    "pulseaudio"
    "cpu"
    "backlight"
    "memory"
    "temperature"
    "battery"
    "tray"
    "custom/power"
  ];

  minimalRight = [
    "network"
    "pulseaudio"
    "battery"
    "tray"
    "custom/power"
  ];

  # restart rather than reload: waybar 0.15 aborts on SIGUSR2 when started with -c/-s
  waybar-mode = pkgs.writeShellScriptBin "waybar-mode" ''
    active="${cfgDir}/config-active.jsonc"
    if [ "$(readlink "$active")" = "${cfgDir}/config-minimal.jsonc" ]; then
      ln -sfn "${cfgDir}/config-full.jsonc" "$active"
    else
      ln -sfn "${cfgDir}/config-minimal.jsonc" "$active"
    fi
    systemctl --user restart waybar
  '';
in {
  config = lib.mkIf config.myConfig.desktop.enable {
    programs.waybar = {
      enable = true;
      systemd.enable = true;

      style = ''
        * {
          font-family: "${font}";
          font-size: 13px;
          min-height: 0;
        }

        window#waybar {
          background: transparent;
          color: ${c.base05};
        }

        .modules-left,
        .modules-center,
        .modules-right {
          background: ${c.base01};
          border-radius: 12px;
          margin: 5px 8px;
          padding: 0 4px;
        }

        #clock,
        #tray,
        #network,
        #pulseaudio,
        #cpu,
        #backlight,
        #memory,
        #temperature,
        #battery,
        #custom-power {
          padding: 2px 10px;
          margin: 3px 1px;
          border-radius: 8px;
          background: transparent;
        }

        #clock:hover,
        #network:hover,
        #pulseaudio:hover,
        #cpu:hover,
        #backlight:hover,
        #memory:hover,
        #temperature:hover,
        #battery:hover,
        #custom-power:hover {
          background: ${c.base02};
        }

        #clock { color: ${c.base05}; font-weight: bold; }
        #tray { color: ${c.base05}; }
        #network { color: ${c.base0C}; }
        #pulseaudio { color: ${c.base0E}; }
        #cpu { color: ${c.base0D}; }
        #backlight { color: ${c.base0A}; }
        #memory { color: ${c.base0B}; }
        #temperature { color: ${c.base09}; }
        #battery { color: ${c.base0B}; }
        #custom-power { color: ${c.base08}; }

        #workspaces button {
          color: ${c.base04};
          padding: 0 8px;
          margin: 3px 2px;
          border-radius: 8px;
          background: transparent;
        }

        #workspaces button:hover {
          background: ${c.base02};
          color: ${c.base05};
        }

        #workspaces button.active {
          background: ${c.base0D};
          color: ${c.base00};
          font-weight: bold;
        }

        #workspaces button.urgent {
          background: ${c.base08};
          color: ${c.base00};
        }

        #battery.warning { color: ${c.base0A}; }
        #battery.critical { color: ${c.base08}; }
        #temperature.critical { color: ${c.base08}; }

        #pulseaudio.muted { color: ${c.base03}; }
      '';
    };

    home.packages = [waybar-mode];

    xdg.configFile = {
      "waybar/config-full.jsonc".text = builtins.toJSON (bar fullRight);
      "waybar/config-minimal.jsonc".text = builtins.toJSON (bar minimalRight);
    };

    # waybar reads a mutable symlink so waybar-mode can swap layouts without a rebuild
    systemd.user.services.waybar.Service.ExecStart =
      lib.mkForce "${config.programs.waybar.package}/bin/waybar -c ${cfgDir}/config-active.jsonc -s ${cfgDir}/style.css";

    home.activation.waybarActiveConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      [ -L "${cfgDir}/config-active.jsonc" ] || run ln -sfn "${cfgDir}/config-full.jsonc" "${cfgDir}/config-active.jsonc"
    '';
  };
}
