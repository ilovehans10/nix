# This file defines overlays
{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });

    tmuxPlugins = prev.tmuxPlugins // {
      battery = prev.tmuxPlugins.battery.overrideAttrs (_oldAttrs: {
        patches = [ ../modules/home-manager/tmux/battery_fix.patch ];
        pluginName = "battery";
        version = "unstable-2025-30-12";
        src = prev.fetchFromGitHub {
          owner = "tmux-plugins";
          repo = "tmux-battery";
          rev = "43832651ede43f54dcf0588727c1957fe648d57d";
          hash = "sha256-kyUrJdraDDye8WEBP2RgHN7kHmafToYtLmrMJ9u0f+0=";
        };
      });
    };
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
