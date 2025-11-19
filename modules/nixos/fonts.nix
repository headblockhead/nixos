{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    powerline
    # google-fonts.out # This adds so many fonts that it breaks most UIs :(
    ubuntu_font_family
    ibm-plex
    source-code-pro
    nerd-fonts._3270
    arkpandora_ttf
  ];
}
