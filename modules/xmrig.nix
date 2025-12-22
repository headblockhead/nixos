{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    xmrig
  ];
  services.xmrig = {
    enable = true;
    package = pkgs.xmrig;
    settings = {
      autosave = true;
      cpu = true;
      pools = [{ url = "172.16.3.51:3333"; }];
    };
  };

  systemd.services.xmrig = {
    #conflicts = [ "xmrig-stop.service" ];
  };

  #  systemd.services.xmrig-stop = {
  #description = "Stop xmrig";
  #serviceConfig = {
  #Type = "oneshot";
  #ExecStart = "${pkgs.coreutils}/bin/true";
  #};
  #};

  #systemd.timers.xmrig-start = {
  #enable = true;
  #wantedBy = [ "timers.target" ];
  #timerConfig = {
  #Unit = "xmrig.service";
  #OnCalendar = "*-*-* 00:30:00";
  #};
  #};
  #systemd.timers.xmrig-stop = {
  #enable = true;
  #wantedBy = [ "timers.target" ];
  #timerConfig = {
  #Unit = "xmrig-stop.service";
  #OnCalendar = "*-*-* 05:30:00";
  #};
  #};
}
