{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    kicad
    prusa-slicer
    libreoffice
    hunspell
    hunspellDicts.en-gb-large
    #anki
    thunderbird
    openscad-unstable
    #freecad-wayland
    texstudio
    texliveFull
    hieroglyphic
    citations
    gnome-decoder
    dialect
    radicle-desktop
  ];
}
