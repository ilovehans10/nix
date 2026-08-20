{...}: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      moss = {
        hostname = "moss.home";
        user = "hans";
        addressFamily = "inet";
        setEnv = {
          TMUX_TMPDIR = "/run/user/1000";
        };
      };
      # sane defaults for all ssh hosts
      "*" = {
        forwardAgent = false;
        serverAliveInterval = 10;
        serverAliveCountMax = 3;
        compression = false;
        addKeysToAgent = "no";
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "auto";
        controlPath = "~/.ssh/socket-%r@%n:%p";
        controlPersist = "no";
      };
    };
  };
}
