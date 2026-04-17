{
  inputs,
  outputs,
  pkgs,
  ...
}:
{
  imports = [
    ../../modules/home-manager
    ../../modules/home-manager/hyprland
    inputs.stylix.homeModules.stylix
    ../../modules/stylix.nix
  ];

  myConfig.desktop.enable = true;
  myConfig.tmux.enable = true;
  myConfig.tmux.battery.enable = true;

  nixpkgs = {
    overlays = [
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
    config = {
      allowUnfree = true;
    };
  };

  home = {
    username = "hans";
    homeDirectory = "/home/hans";
    pointerCursor = {
      name = "Dracula-cursors";
      package = pkgs.dracula-theme;
      size = 24;

      gtk.enable = true;

      x11 = {
        enable = true;
        defaultCursor = "Dracula-cursors";
      };
    };
  };

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";

  home.stateVersion = "23.05";
}
