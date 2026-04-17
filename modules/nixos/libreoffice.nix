{ lib, config, pkgs, ... }: {
  options.myConfig.libreoffice.enable = lib.mkEnableOption "LibreOffice office suite";

  config = lib.mkIf config.myConfig.libreoffice.enable {
    environment.systemPackages = with pkgs; [
      libreoffice
      hunspell
      hunspellDicts.en-us
    ];
  };
}
