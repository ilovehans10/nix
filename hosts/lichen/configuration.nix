{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:
{
  imports = [
    ../../modules/nixos
    inputs.stylix.nixosModules.stylix
    ../../modules/stylix.nix
    ./hardware-configuration.nix
  ];

  myConfig.libreoffice.enable = true;
  myConfig.sanoid.enable = true;

  nixpkgs = {
    overlays = [
      inputs.rust-overlay.overlays.default
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
    ];
    config = {
      allowUnfree = true;
    };
  };

  nix =
    let
      flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
    in
    {
      settings = {
        experimental-features = "nix-command flakes";
        nix-path = config.nix.nixPath;
      };
      channel.enable = false;
      registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
      nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
    };

  networking.hostName = "lichen";
  networking.hostId = "74e2c635";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Chicago";

  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver = {
    excludePackages = with pkgs; [ xterm ];
    enable = true;
  };

  programs.hyprland.enable = true;

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "hans" ];
  };

  programs.steam = {
    enable = true;
    extraPackages = with pkgs; [ nss ];
  };

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

  services.fwupd.enable = true;

  services.fprintd.enable = true;

  security.polkit.enable = true;

  services.fail2ban.enable = true;

  services.openssh = {
    enable = true;
    ports = [ 5522 ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "hans" ];
    };
  };

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
      extraGroups = [
        "wheel"
        "networkmanager"
      ];
    };
  };

  users.defaultUserShell = pkgs.zsh;
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
    acpi
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
    rust-bin.stable.latest.default
    tmux

    # Shell and utilities
    bat
    blueman
    brightnessctl
    dig
    exiftool
    ffmpeg
    fzf
    hyprpicker
    hyprshot
    jq
    libnotify
    lsd
    nh
    pwvucontrol
    ripgrep
    waybar
    wl-clipboard
    yazi
    zoxide
    zsh

    # Resources
    whitesur-gtk-theme

    # Applications
    discord
    firefox
    kitty
    localsend
    qalculate-qt

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

  system.stateVersion = "23.05";
}
