{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    libreoffice
    hunspell
    hunspellDicts.en-us
  ];
}
