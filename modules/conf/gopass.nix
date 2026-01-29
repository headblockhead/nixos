{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gopass
  ];
}
