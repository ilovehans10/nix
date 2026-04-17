# Placeholder — replace with output of `sudo nixos-generate-config` on the server.
{
  lib,
  modulesPath,
  ...
}: {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot.loader.grub = {
    enable = true;
    devices = ["/dev/sda"];
  };

  fileSystems."/" = {
    device = "/dev/sda1";
    fsType = "ext4";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
