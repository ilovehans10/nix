# Lazygit is a simple terminal UI for git commands.
{ config, lib, ... }: {
  programs.lazygit = {
    enable = true;
    settings = lib.mkForce {
      disableStartupPopups = true;
      notARepository = "skip";
      promptToReturnFromSubprocess = false;
      update.method = "never";
      git = {
        commit.signOff = true;
        parseEmoji = true;
      };
      gui = {
        useHunkModeInStagingView = true;
        nerdFontsVersion = "3";
      };
    };
  };
}
