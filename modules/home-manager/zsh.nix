{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.zsh = {
    enable = true;
    autocd = true;
    dotDir = "${config.xdg.configHome}/zsh";
    autosuggestion.enable = true;
    enableCompletion = true;

    # Set vi mode
    defaultKeymap = "viins";

    dirHashes = {
      bitburner = "$HOME/Games/typescript-template/src/";
      nix = "$HOME/Documents/nix-full/";
      wallpapers = "$HOME/Pictures/wallpapers/";
    };

    # History configuration
    history = {
      size = 10000;
      save = 50000;
      path = "$ZDOTDIR/.zsh_history";
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

    envExtra = ''
      ZVM_INIT_MODE="sourcing"
      setopt no_global_rcs
    '';

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

        # Enable run-help for builtins
        unalias run-help 2>/dev/null || true
        autoload run-help

        source $HOME/.config/zsh/.p10k.zsh

        # Cleanup
        unset FRESHSHELL
      '';
    in
      lib.mkMerge [zshConfigEarlyInit zshConfig];

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

  # Zoxide integration
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
}
