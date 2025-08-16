# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{ inputs, outputs, lib, config, pkgs, ... }: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  home = {
    username = "hans";
    homeDirectory = "/home/hans";
    pointerCursor = {
      name = "Dracula-cursors";
      package = pkgs.dracula-theme;
      size = 24;

      gtk.enable = true;

      x11 = {
        enable = true;
        defaultCursor = "Dracula-cursors";
      };
    };
  };

  # Add stuff for your user as you see fit:
  # home.packages = with pkgs; [ steam ];

  # Enable home-manager and git
  programs.home-manager.enable = true;

  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      # Dependent packages used by default plugins
      doq
      sqlite
      cargo
      clang
      cmake
      gcc
      gnumake
      pkg-config
      yarn
    ];
    extraLuaPackages = ls:
      with ls; [
        luarocks
        # required by 3rd/image.nvim
        magick
      ];
  };

  programs.zsh = {
    enable = true;
    autocd = true;
    dotDir = ".config/zsh";
    autosuggestion.enable = true;
    enableCompletion = true;

    # Set vi mode
    defaultKeymap = "viins";

    # History configuration
    history = {
      size = 10000;
      save = 10000;
      ignoreDups = true;
      ignoreSpace = true;
      extended = true;
    };

    # Environment variables
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      BROWSER = "firefox";
      DOTFILES_LOCATION = "$HOME/.dotfiles";
    };

    # Shell options
    #setOptions = [
    #  "HIST_VERIFY"
    #  "SHARE_HISTORY"
    #  "EXTENDED_HISTORY"
    #  "HIST_IGNORE_DUPS"
    #  "HIST_IGNORE_SPACE"
    #  "HIST_REDUCE_BLANKS"
    #  "HIST_SAVE_NO_DUPS"
    #  "INTERACTIVE_COMMENTS"
    #  "MAGIC_EQUAL_SUBST"
    #  "NULL_GLOB"
    #  "NUMERIC_GLOB_SORT"
    #  "RC_EXPAND_PARAM"
    #];

    # Aliases
    shellAliases = {
      # Text editors
      editnixconf = "sudo -e /etc/nixos/configuration.nix";
      vi = "nvim";
      vim = "nvim";
      vimdiff = "nvim -d";
      vimrc = "nvim $HOME/.config/nvim/init.lua";
      zshrc = "nvim $HOME/.config/zsh/.zshrc";

      # Git and dotfiles
      lg = "lazygit";
      dotfiles = "lg -p $DOTFILES_LOCATION";
      config = "/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME";

      # System utilities
      duls = "du -hd1";
      df = "df -h";
      lsds = "du -hd1 | sort -h";
      mkdir = "mkdir -pv";
      cat = "bat";
      cd = "z";
      ls = "lsd";

      # Media and downloads
      youtube-dl = "yt-dlp";
      yt = "yt-dlp";
      pause = "playerctl pause";
      play = "playerctl play";

      # System management
      sss = "sudo systemctl suspend";
      zsource = "exec zsh";

      # Utilities
      rsync = "noglob rsync --exclude-from=$HOME/.config/git/gitignore";
      mvr = "rsync -Ph";
      sudo = "sudo "; # Preserve aliases with sudo

      # Top commands
      top10 = "print -l \${(o)history%% *} | uniq -c | sort -nr | head -n 10";
    };

    # Zsh plugins managed by Nix
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
      {
        name = "zsh-vi-mode";
        src = pkgs.zsh-vi-mode;
        file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
      }
    ];

    # Custom zshrc ordering
    initContent = let
      zshConfigEarlyInit = lib.mkOrder 500 ''
        # Enable Powerlevel10k instant prompt
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi
      '';
      zshConfig = lib.mkOrder 1000 ''
        # Fresh shell detection and tips
        [ "$ZSH_EVAL_CONTEXT" = file ] && FRESHSHELL=true
        [ "$FRESHSHELL" = true ] && [ -f "$HOME/.config/zsh/tips" ] && \
        sed -e 's/^#.*$//' -e '/^$/d' -e 's/^\(.*\): \(.*\)$/\\\\033[1m\1: \\\\033[0;92m\2\\\\033[0m/' "$HOME/.config/zsh/tips" | \
        shuf -n1 | xargs -I % printf "%\n"

        # Custom functions
        ses() {
          sudo systemctl enable "$@" && sudo systemctl start "$@"
        }

        sds() {
          sudo systemctl disable "$@" && sudo systemctl stop "$@"
        }

        yy() {
          local tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
          yazi "$@" --cwd-file="$tmp"
          if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
            cd -- "$cwd"
          fi
          rm -f -- "$tmp"
        }

        addtip() {
          echo "$@" >> "$HOME/.config/zsh/tips"
        }

        tip() {
          sed -e 's/^#.*$//' -e '/^$/d' "$HOME/.config/zsh/tips" | shuf -n"''${1:-1}"
        }

        tipgrep() {
          grep -i $1 <(sed -e 's/^#.*$//' -e '/^$/d' "$HOME/.config/zsh/tips")
        }

        getline() {
          head -n "$1" "$2" | tail -n 1
        }

        findw() {
          find . | grep "$1" 2>/dev/null
        }

        findl() {
          find . | grep "$1" 2>/dev/null | less
        }

        timezsh() {
          shell=''${1-$SHELL}
          for _ in $(seq 1 10); do /usr/bin/time -p "$shell" -i -c exit; done
        }

        rgl() {
          rg --color=always $@ | less
        }

        # Keybinds
        #bindkey "^I" vi-forward-char

        # Enable run-help for builtins
        unalias run-help 2>/dev/null || true
        autoload run-help

        source $HOME/.config/zsh/.p10k.zsh

        # Cleanup
        unset FRESHSHELL
      '';
    in lib.mkMerge [ zshConfigEarlyInit zshConfig ];

    # Local variables for different configurations
    localVariables = {
      # FZF configuration
      FZF_DEFAULT_COMMAND = "rg --files --hidden --follow --glob '!.git'";
    };
  };

  # FZF integration
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.git = {
    enable = true;
    userEmail = "hanandlia@gmail.com";
    userName = "Hans Larsson";
    extraConfig = ''
      [Host "*"]
      	IdentityAgent = "~/.1password/agent.sock"'';
  };

  # Zoxide integration
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Tmux setup
  programs.tmux = {
    enable = true;
    focusEvents = true;
    historyLimit = 100000;
    keyMode = "vi";
    terminal = "screen-256color";
    #plugins = []
    prefix = "C-Space";
    sensibleOnTop = true;
    plugins = with pkgs; [
      tmuxPlugins.catppuccin
      tmuxPlugins.open
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = "set -g @resurrect-strategy-nvim 'session'";
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '60' # minutes
        '';
      }
    ];
    extraConfig = ''
      # set configuration options
      set-option -sa terminal-features ',screen-256color:RGB' # turn on tmux color support
      set-option -g display-time 4000 # make tmux notifications last 4 seconds
      set-option -g allow-passthrough on

      bind-key r source-file $HOME/.config/tmux/tmux.conf # reload tmux config on <C-Space>r

      bind-key -T copy-mode-vi v send -X begin-selection
      bind-key -T copy-mode-vi V send -X select-line
      bind-key -T copy-mode-vi y send -X copy-pipe-and-cancel 'xclip -in -selection clipboard'

      # smart pane switching with awareness of Vim splits.
      # see: https://github.com/christoomey/vim-tmux-navigator
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
      | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
      bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
      bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
      bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
      bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
      tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
      if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
        "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
      if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
        "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

      bind-key -T copy-mode-vi 'C-h' select-pane -L
      bind-key -T copy-mode-vi 'C-j' select-pane -D
      bind-key -T copy-mode-vi 'C-k' select-pane -U
      bind-key -T copy-mode-vi 'C-l' select-pane -R
      bind-key -T copy-mode-vi 'C-\' select-pane -l

      # set my custom status bar
      set-option -g status-right "#{?client_prefix,[PREFIX] ,}"
      set-option -ag status-right "#h "
      set-option -ag status-right "%H:%M %d-%a"
    '';
  };

  programs.kitty = {
    enable = true;
    font.name = "DejaVuSansM Nerd Font Mono";
  };

  # Waybar setup
  programs.waybar = {
    enable = true;
    systemd.enable = true;
  };

  # xdg user dir setup
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  # swww setup
  services.swww.enable = true;

  wayland.windowManager.hyprland = {
    enable = true;
    package = pkgs.hyprland;
    systemd = {
      enable = true;
      enableXdgAutostart = true;
      variables = [ "--all" ];
    };
    xwayland = { enable = true; };
    settings = {
      cursor = {
        sync_gsettings_theme = true;
        no_hardware_cursors = 2; # change to 1 if want to disable
        enable_hyprcursor = false;
        warp_on_change_workspace = 2;
        no_warps = true;
      };
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
