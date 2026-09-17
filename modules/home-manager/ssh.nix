{...}: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      moss = {
        HostName = "moss.home";
        User = "hans";
        AddressFamily = "inet";
        SetEnv = {
          TMUX_TMPDIR = "/run/user/1000";
        };
      };
      # sane defaults for all ssh hosts
      "*" = {
        ForwardAgent = false;
        ServerAliveInterval = 10;
        ServerAliveCountMax = 3;
        Compression = false;
        AddKeysToAgent = "no";
        HashKnownHosts = false;
        UserKnownHostsFile = "~/.ssh/known_hosts";
        ControlMaster = "auto";
        ControlPath = "~/.ssh/socket-%r@%n:%p";
        ControlPersist = "no";
      };
    };
  };
}
