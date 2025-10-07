{ lib, pkgs, ... }: {
  programs.git = {
    enable = true;
    userEmail = "hanandlia@gmail.com";
    userName = "Hans Larsson";
    extraConfig = {
      gpg = { format = "ssh"; };
      "gpg \"ssh\"" = {
        program = "${lib.getExe' pkgs._1password-gui "op-ssh-sign"}";
      };
      commit = { gpgsign = true; };
      user = {
        signingKey =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG0zfpzv87Do8FuepBA1r6PbibGI94dCS+STwv2B5WJN";
      };
      merge.conflictStyle = "diff3";
      push.default = "simple"; # Match modern push behavior
      color.ui = "auto";
      diff = {
        tool = "vimdiff";
        submodule = "log";
      };
      difftool.prompt = false;
      # FOSS-friendly settings
      credential.helper = "cache --timeout=7200";
      log.decorate = "full"; # Show branch/tag info in git log
      log.date = "iso"; # ISO 8601 date format
    };
  };
}
