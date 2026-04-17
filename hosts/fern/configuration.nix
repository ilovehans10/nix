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

  networking.hostName = "fern";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Chicago";

  i18n.defaultLocale = "en_US.UTF-8";

  programs.zsh.enable = true;

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  services.fail2ban.enable = true;

  services.openssh = {
    enable = true;
    ports = [ 22 ];
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
      Defaults        timestamp_timeout=15
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
        "podman"
      ];
    };
  };

  users.defaultUserShell = pkgs.zsh;
  environment.pathsToLink = [ "/share/zsh" ];

  environment.systemPackages = with pkgs; [
    bottom
    curl
    git
    home-manager
    htop
    jq
    nmap
    ripgrep
    tree
    unzip
    wget
    zip
  ];

  system.stateVersion = "25.11";
}
