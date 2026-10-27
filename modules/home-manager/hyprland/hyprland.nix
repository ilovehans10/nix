{
  config,
  lib,
  ...
}: let
  cursor = config.home.pointerCursor;
  workspaces =
    builtins.genList (i: let
      ws = toString (i + 1);
      key = toString (lib.mod (i + 1) 10);
    in [
      "$mainMod, ${key}, workspace, ${ws}"
      "$mainMod SHIFT, ${key}, movetoworkspace, ${ws}"
    ])
    10;
in {
  # stylix supplies border colors; wallpaper stays with services.hyprpaper in desktop.nix
  stylix.targets.hyprland = {
    enable = true;
    hyprpaper.enable = false;
  };

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "hyprlang";
    # NixOS programs.hyprland provides the package; UWSM owns the session target
    package = null;
    systemd.enable = false;

    settings = {
      monitor = ",1920x1080@60,auto,1";

      exec-once = ["uwsm app -- 1password --silent"];

      env = [
        "XCURSOR_THEME,${cursor.name}"
        "XCURSOR_SIZE,${toString cursor.size}"
        "HYPRCURSOR_THEME,${cursor.name}"
        "HYPRCURSOR_SIZE,${toString cursor.size}"
      ];

      input = {
        kb_layout = "us";
        kb_options = "caps:escape";
        follow_mouse = 1;
        sensitivity = 0;
        touchpad = {
          natural_scroll = true;
          disable_while_typing = false;
        };
      };

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 1;
        layout = "dwindle";
        allow_tearing = false;
      };

      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
      };

      animations = {
        enabled = true;
        bezier = ["myBezier, 0.05, 0.9, 0.1, 1.05"];
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "borderangle, 1, 8, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      dwindle.preserve_split = true;

      gesture = ["3, horizontal, workspace"];

      misc.force_default_wallpaper = 0;

      "$mainMod" = "SUPER";

      bind =
        [
          "$mainMod, return, exec, kitty"
          "SUPER_SHIFT, w, exec, firefox"
          "$mainMod, V, togglefloating,"
          "$mainMod, D, exec, vicinae toggle"
          "$mainMod, Q, killactive,"
          "$mainMod, F, fullscreen,"
          "$mainMod, B, exec, waybar-mode"
          "$mainMod, P, exec, 1password --quick-access"
          "$mainMod, space, exec, 1password --quick-access"

          ", Print, exec, hyprshot --clipboard-only -m region"
          "Shift, Print, exec, hyprshot --clipboard-only -m window -m active"
          "$mainMod, Print, exec, hyprshot -o ~/Pictures/screenshots -m region"
          "SUPER_SHIFT, Print, exec, hyprshot -o ~/Pictures/screenshots -m window -m active"

          "$mainMod, h, movefocus, l"
          "$mainMod, l, movefocus, r"
          "$mainMod, k, movefocus, u"
          "$mainMod, j, movefocus, d"

          "$mainMod SHIFT, h, movewindow, l"
          "$mainMod SHIFT, l, movewindow, r"
          "$mainMod SHIFT, k, movewindow, u"
          "$mainMod SHIFT, j, movewindow, d"

          "$mainMod, S, togglespecialworkspace, magic"
          "$mainMod SHIFT, S, movetoworkspace, special:magic"

          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"
          "SUPER_CTRL, h, workspace, e-1"
          "SUPER_CTRL, l, workspace, e+1"
        ]
        ++ builtins.concatLists workspaces;

      bindel = [
        ", XF86MonBrightnessUp, exec, brightnessctl s +5%"
        ", XF86MonBrightnessDown, exec, brightnessctl s 5%-"
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];

      bindl = [
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioNext, exec, playerctl next"
      ];

      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
    };
  };
}
