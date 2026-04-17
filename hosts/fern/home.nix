{
  inputs,
  outputs,
  ...
}: {
  imports = [
    ../../modules/home-manager
    inputs.stylix.homeModules.stylix
    ../../modules/stylix.nix
  ];

  myConfig.tmux.enable = true;

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
  };

  programs.home-manager.enable = true;

  systemd.user.startServices = "sd-switch";

  home.stateVersion = "25.11";
}
