{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    powerline
    ubuntu-classic
    ibm-plex
    source-code-pro
    nerd-fonts._3270
    arkpandora_ttf
  ];
}
