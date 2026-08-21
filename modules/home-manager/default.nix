# Add your reusable home-manager modules to this directory, on their own file (https://nixos.wiki/wiki/Module).
# These should be stuff you would like to share with others, not your personal configurations.
{pkgs, ...}: {
  imports = [
    ./desktop.nix
    ./git.nix
    ./lazygit.nix
    ./nvim
    ./services
    ./ssh.nix
    ./tmux
    ./vicinae.nix
    ./xdg.nix
    ./yazi.nix
    ./zsh.nix
  ];
  programs.gpg.enable = true;
}
