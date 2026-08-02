{
  boot.loader.raspberry-pi.bootloader = "kernel";
  hardware.raspberry-pi.config.all.base-dt-params = {
    pciex1 = {
      enable = true;
      value = "on";
    };
    pciex1_gen = {
      enable = true;
      value = 3;
    };

    act_led_trigger = {
      # green activity led behavior = off
      enable = true;
      value = "none";
    };
    pwr_led_trigger = {
      # red power led behavior = off
      enable = true;
      value = "none";
    };

    eth_led0 = {
      # green ethernet led behavior = off
      enable = true;
      value = 4;
    };
    eth_led1 = {
      # amber ethernet led behavior = link
      enable = true;
      value = 8;
    };
  };
  nixpkgs.hostPlatform = "aarch64-linux";
}
