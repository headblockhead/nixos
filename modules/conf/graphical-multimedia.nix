{ pkgs, config, ... }:
{
  # For OBS virtual camera.
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  environment.systemPackages = with pkgs; [
    spotify
    obs-studio
    raysession
    audacity
    easyeffects
  ];
}
