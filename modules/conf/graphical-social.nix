{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    signal-desktop-bin
    slack
    fractal
  ];
}
