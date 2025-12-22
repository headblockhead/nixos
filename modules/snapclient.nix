{ pkgs, ... }:
{
  systemd.user.services.snapclient-local = {
    wants = [
      "pipewire.service"
      "network-online.target"
    ];
    after = [
      "pipewire.service"
      "network-online.target"
    ];
    serviceConfig = {
      ExecStart = "${pkgs.snapcast}/bin/snapclient -h gateway";
    };
  };
}
