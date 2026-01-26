{
  networking.firewall.allowedTCPPorts = [ 9002 8019 ];

  boot.kernelModules = [ "i2c-dev" ];
  hardware.raspberry-pi.config.all.base-dt-params = {
    i2c_arm = {
      enable = true;
      value = "on";
    };
  };

  services.keepalived.vrrpInstances.haproxy_vip = {
    state = "BACKUP";
    priority = 100;
  };
}
