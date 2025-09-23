# This is your system's configuration file.
# Use this to configure your system environment (it replaces /etc/nixos/configuration.nix)
{ inputs, outputs, lib, config, pkgs, ... }: {
  # You can import other NixOS modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/nixos):
    # outputs.nixosModules.example

    # Or modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix

    # Import your generated (nixos-generate-config) hardware configuration
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  nix = let flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
  in {
    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Workaround for https://github.com/NixOS/nix/issues/9574
      nix-path = config.nix.nixPath;
    };
    # Opinionated: disable channels
    channel.enable = false;

    # Opinionated: make flake registry and nix path match flake inputs
    registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
    nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
  };

  # Define hostname
  networking.hostName = "lichen";
  # Define hostId for zfs
  networking.hostId = "74e2c635";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Chicago";

  i18n.defaultLocale = "en_US.UTF-8";

  # Add kmscon for a more dynamic tty
  services.kmscon = {
    enable = true;
    fonts = [{
      name = "DejaVuSansM Nerd Font Mono";
      package = pkgs.nerd-fonts.dejavu-sans-mono;
    }];
  };

  services.xserver = {
    # Disable xterm
    excludePackages = with pkgs; [ xterm ];

    # Enable the X11 windowing system.
    enable = true;
  };

  programs.hyprland.enable = true; # enable Hyprland

  programs._1password.enable = true;
  programs._1password-gui.enable = true;

  programs.steam.enable = true;

  programs.zsh.enable = true;

  services.pipewire = {
    enable = true;
    audio.enable = true;
    pulse.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    jack.enable = true;
  };

  services.libinput.enable = true;
  services.libinput.touchpad.disableWhileTyping = false;
  services.libinput.mouse.disableWhileTyping = false;

  services.fwupd.enable = true;

  security.sudo = {
    enable = true;
    extraConfig = ''
      Defaults        timestamp_timeout=-1
    '';
  };

  users.users = {
    hans = {
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCqaem9ZdmLSCHtGqWBVPN7jnwQSfeHmJISYD0myw5/L4RdI2fSatxcQoZoP0htcpsxAPa+Jnj2MTPX1ZIe4F+wQd8kBp/Tpw3mLbQkEqo2U29bRC660FfJVsSi0Jx/GXu1B11QBjNQgH+XfEqoEA+vn9IEClIl/1eS3/aO85an6UvPxgWnBesx+CXbIMbvSNNjvLD5NF2gCPlPI4SHqBCC1dAviavdgAGkjVQ3sqrXKQifLeD73Cu0qJAOGGjyq2HfLP+jQmxEXn4z2vCYr7HM0VzPnoz72HgBbYTP/IQOgGEKxLMK/wExel77Z2e/m72UQBZRXCYbYH1KVzWpH5/7o0KRS9LAmJf+G1UpTsaRHiCaihcAtNMTtgW855YIoXjZjBJyM9zCccA3qICwpAuvsXyl5eCoyKWQaXmNuhmTyJw5OPcBYJWB0E/AUKWIzfufg+/cFce7df1gpFmL3A9IcaO58cnjZt7UZ5d5FgdysQkPi0bieFZUfq2owW4KlhE="
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC0LLilDa9B86VVViCaEdQeuOEUx/y0WK71VUqCwcxGhRST0E1xWEgGZGRqUBr26Ib3MTIBcOIIsKQ9Qy4fb6NY+MQVUZgtVrcYMOGvNiObVCns+az7KngzCLc/eN5bzZV976d9WygrvI1AHZdK/kCzQ05ZMBVM5XHlNUrat6/KRzYdLArwn1FlVyVY7C63K6p19FbouwYwO/Ywpa/trq7Vi6d+h8aRRj8rihZhSILF+/lcvb+n7TzQj5LSKd5PYWBUbMvi2ob9knnVW5Un7qaB/pc1t6brDC41XYJFmqKNd2I0PupKQuCM4qxuT6fZuJPAwP4pPg/ZE47YlCkGWLKarwpU+AydBVqUEEX+rhbBYFurQ7WjXTKmKIMEn3qzdDgE4bKq2NKBX6NtdUN+VKVEuCS8F51iQYzI9uMKk9coPVKKSgdQypzKhyons5JP3mbTLuwZTFotoPj0cf0WhLQqABV5GZMHKQFKbLe30qvpfuP+AfqKcYnZO2g/g/cUnc0="
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICEamsn2ceY2BwGEnnXMDaTpP1i/nW1893BrVC+uhWGs"
      ];
      extraGroups = [ "wheel" "networkmanager" ];
    };
  };

  users.defaultUserShell = pkgs.zsh;
  # This allows systemd completion in zsh
  environment.pathsToLink = [ "/share/zsh" ];

  environment.variables = {
    GTK_THEME = "WhiteSur-Dark";
    XCURSOR_THEME = "WhiteSur-Dark";
    XCURSOR_SIZE = "24";
    HYPRCURSOR_THEME = "WhiteSurDark";
    HYPRCURSOR_SIZE = "24";
  };

  xdg.mime.defaultApplications = {
    "image/jpg" = "sxiv.desktop";
    "image/jpeg" = "sxiv.desktop";
    "image/png" = "sxiv.desktop";
  };

  environment.systemPackages = with pkgs; [
    # Core system tools
    bc
    bottom
    curl
    git
    home-manager
    nmap
    tree
    unzip
    wget
    zip

    # Development tools
    lazygit
    neovim
    tmux

    # Shell and utilities
    bat
    blueman
    brightnessctl
    dig
    exiftool
    ffmpeg
    fzf
    lsd
    nh
    pwvucontrol
    ripgrep
    tmux
    waybar
    yazi
    zoxide
    zsh

    # Resources
    whitesur-gtk-theme

    # Applications
    discord
    firefox
    gcc
    kitty
    localsend
    rustup
    wofi

    # Media and downloads
    gimp3
    imagemagick
    mpv
    playerctl
    sxiv
    yt-dlp
    zathura
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.droid-sans-mono
    nerd-fonts.bitstream-vera-sans-mono
    nerd-fonts.departure-mono
    nerd-fonts.dejavu-sans-mono
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05";
}
