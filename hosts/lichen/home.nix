{
  inputs,
  outputs,
  pkgs,
  ...
}: {
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
      name = "catppuccin-mocha-dark-cursors";
      package = pkgs.catppuccin-cursors.mochaDark;
      size = 24;

      gtk.enable = true;
      hyprcursor.enable = true;
      x11.enable = true;
    };
  };

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";

  home.stateVersion = "23.05";
}
