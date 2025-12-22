{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.yubikey-personalization
    pkgs.yubikey-manager
    pkgs.yubikey-touch-detector
    pkgs.yubioath-flutter
  ];
  services.pcscd.enable = true;
  systemd.services.pcscd = {
    wantedBy = [ ];
  };
}
