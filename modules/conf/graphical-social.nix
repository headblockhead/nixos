{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    signal-desktop
    slack
    fractal
    tuba
  ];
}
