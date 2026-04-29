{
  lib,
  config,
  pkgs,
  ...
}: {
  options.myConfig.tmux = {
    enable = lib.mkEnableOption "tmux terminal multiplexer";
    battery.enable = lib.mkEnableOption "battery status in the tmux status bar";
  };

  config = lib.mkIf config.myConfig.tmux.enable {
    programs.tmux = {
      enable = true;
      focusEvents = true;
      historyLimit = 100000;
      keyMode = "vi";
      terminal = "screen-256color";
      prefix = "C-Space";
      sensibleOnTop = true;
      plugins = with pkgs;
        [
          tmuxPlugins.catppuccin
          {
            plugin = tmuxPlugins.mkTmuxPlugin {
              pluginName = "suspend";
              version = "unstable-2024-01-15";
              src = fetchFromGitHub {
                owner = "MunifTanjim";
                repo = "tmux-suspend";
                rev = "1a2f806666e0bfed37535372279fa00d27d50d14";
                hash = "sha256-+1fKkwDmr5iqro0XeL8gkjOGGB/YHBD25NG+w3iW+0g=";
              };
            };
            extraConfig = ''
              set -g @suspend_key "F12"
              set -g @hostname_bg "#cba6f7"
              set -g @suspend_suspended_options " @mode_indicator_custom_prompt:: SUSPENDED , @hostname_bg::#f38ba8, "
              run-shell 'tmux set-option @mode_indicator_custom_prompt " $(hostname -s) "'
            '';
          }
        ]
        ++ lib.optionals config.myConfig.tmux.battery.enable [
          {
            plugin = tmuxPlugins.battery;
            extraConfig = ''
              set-option -g @batt_remain_short 'true'
              set-option -g status-right "#{?client_prefix,[PREFIX] ,}#[bg=#f9e2af,fg=#1e1e2e] #{battery_percentage}#{?#{battery_remain}, #{battery_remain},} #[bg=#89b4fa,fg=#1e1e2e] %d-%a %H:%M #[bg=#{@hostname_bg},fg=#1e1e2e] #{@mode_indicator_custom_prompt} "
            '';
          }
        ]
        ++ [
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
        set-option -g status-right-length 65

        set-option -g automatic-rename on
        set-option -g automatic-rename-format "#{?#{==:#{pane_current_command},zsh},#{=15:b:pane_current_path},#{pane_current_command}}"

        ${lib.optionalString (!config.myConfig.tmux.battery.enable) ''
          set-option -g status-right "#{?client_prefix,[PREFIX] ,}#[bg=#89b4fa,fg=#1e1e2e] %d-%a %H:%M #[bg=#{@hostname_bg},fg=#1e1e2e] #{@mode_indicator_custom_prompt} "
        ''}

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
      '';
    };
  };
}
