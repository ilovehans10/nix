{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    focusEvents = true;
    historyLimit = 100000;
    keyMode = "vi";
    terminal = "screen-256color";
    prefix = "C-Space";
    sensibleOnTop = true;
    plugins = with pkgs; [
      tmuxPlugins.catppuccin
      {
        plugin = tmuxPlugins.battery;
        extraConfig = ''
          set-option -g @batt_remain_short 'true'
          set-option -g status-right "#{?client_prefix,[PREFIX] ,} #h #{battery_percentage} #{battery_remain} %H:%M %d-%a"
        '';
      }
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
    '';
  };
}
