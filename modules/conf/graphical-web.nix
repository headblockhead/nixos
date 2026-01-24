{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    firefox
    tor-browser
  ];
}
