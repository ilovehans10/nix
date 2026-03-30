{ pkgs, lib, config, ... }: {
  stylix.targets.yazi.enable = true;

  # yazi 25.5.31 uses first-match-wins for filetype rules. mime = "inode/directory"
  # must appear before the mime = "*" catch-all, so we take ownership of the full
  # rules list. Colors are sourced from Stylix's palette to stay scheme-agnostic.
  programs.yazi.theme.filetype.rules = lib.mkForce (
    let c = config.lib.stylix.colors.withHashtag; in [
      { mime = "image/*";               fg = c.base0C; }
      { mime = "video/*";               fg = c.base0A; }
      { mime = "audio/*";               fg = c.base0A; }
      { mime = "application/zip";       fg = c.base0E; }
      { mime = "application/gzip";      fg = c.base0E; }
      { mime = "application/tar";       fg = c.base0E; }
      { mime = "application/bzip";      fg = c.base0E; }
      { mime = "application/bzip2";     fg = c.base0E; }
      { mime = "application/7z-compressed"; fg = c.base0E; }
      { mime = "application/rar";       fg = c.base0E; }
      { mime = "application/xz";        fg = c.base0E; }
      { mime = "application/doc";       fg = c.base0B; }
      { mime = "application/pdf";       fg = c.base0B; }
      { mime = "application/rtf";       fg = c.base0B; }
      { mime = "application/vnd.*";     fg = c.base0B; }
      { mime = "inode/directory";       fg = c.base0D; bold = true; }
      { mime = "*";                     fg = c.base05; }
    ]
  );

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      mgr = {
        sort_dir_first = true;
        show_hidden = false;
        scrolloff = 5;
      };
    };
    plugins = { smart-enter = pkgs.yaziPlugins.smart-enter; };
    initLua = ''
      require("smart-enter"):setup {
        open_multi = true,
      }
    '';
  };
}
