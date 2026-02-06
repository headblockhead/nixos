{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    git
    vim
    silver-searcher
    p7zip
    btop
    tree
    file
    killall
    pciutils
    usbutils
    inetutils
    lm_sensors
    dig
    ethtool
  ];
}
