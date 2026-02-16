{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    kicad
    prusa-slicer
    libreoffice
    hunspell
    hunspellDicts.en-gb-large
    anki
    thunderbird
    # CAD
    openscad-unstable
    freecad-wayland
    # LaTeX tools
    texstudio
    texliveFull
    hieroglyphic
citations

collision

    gnome-graphs
gnome-decoder
   dialect
 
    forge-sparks

    wike
    wordbook

    textpieces

    share-preview
  ];
}
