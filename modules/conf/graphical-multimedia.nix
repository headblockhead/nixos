{ pkgs, config, ... }:
{
  # For OBS virtual camera.
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];
  environment.systemPackages = with pkgs; [
    # Audio
    spotify
    audacity
    easyeffects
    # Video
    # AV
    obs-studio
    # Images
    identity
    switcheroo
    curtail
    gimp
    inkscape
  ];
}
