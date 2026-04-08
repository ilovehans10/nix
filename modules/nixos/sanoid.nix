{ ... }: {
  services.sanoid = {
    enable = true;
    datasets = {
      "zpool/home" = { useTemplate = [ "production" ]; };
      "zpool/root" = { useTemplate = [ "production" ]; };
      "zpool/var"  = { useTemplate = [ "production" ]; };
      # zpool/nix is omitted — fully reproducible from the flake
    };
    templates.production = {
      hourly  = 24;
      daily   = 7;
      monthly = 12;
      autosnap  = true;
      autoprune = true;
    };
  };
}
