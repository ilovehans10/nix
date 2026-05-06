# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'
pkgs: {
  lenovo-thinkpad-efi-grub-theme = pkgs.callPackage ./lenovo-thinkpad-efi-grub-theme {};
}
