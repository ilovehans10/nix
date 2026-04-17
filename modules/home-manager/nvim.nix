{pkgs, ...}: {
  xdg.configFile."nvim/init.lua".source = ./nvim/init.lua;

  programs.neovim = {
    enable = true;

    extraPackages = with pkgs; [
      # Build tools
      gnumake
      gcc
      clang
      cmake
      pkg-config
      # Formatters and LSP binaries
      unstable.stylua
      alejandra
      lua-language-server
      rust-analyzer
      # Runtime dependencies
      doq
      sqlite
      cargo
      dotnetCorePackages.sdk_9_0
      powershell
      yarn
      nodejs_24
    ];

    extraLuaPackages = ls: with ls; [luarocks];

    plugins = with pkgs.vimPlugins; [
      # Theme
      catppuccin-nvim

      # UI
      lualine-nvim
      bufferline-nvim
      which-key-nvim
      nvim-web-devicons

      # Editor utilities
      mini-nvim
      vim-tmux-navigator
      undotree
      vim-fugitive

      # File explorer
      neo-tree-nvim
      nui-nvim

      # Telescope
      telescope-nvim
      telescope-fzf-native-nvim
      telescope-ui-select-nvim
      plenary-nvim

      # LSP
      nvim-lspconfig
      lazydev-nvim
      fidget-nvim
      mason-nvim
      mason-lspconfig-nvim

      # Completion
      blink-cmp
      luasnip
      friendly-snippets

      # Treesitter — grammars installed by Nix, no :TSUpdate or ensure_installed needed
      (nvim-treesitter.withPlugins (p:
        with p; [
          bash
          c_sharp
          lua
          nix
          vimdoc
        ]))
      nvim-treesitter-context

      # Formatting
      conform-nvim

      # Language support
      rust-vim
    ];
  };
}
