{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    #    signal-desktop # depends on insecure pnpm
    slack
    fractal
    tuba
  ];
}
