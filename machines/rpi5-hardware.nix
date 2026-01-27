{
  boot.loader.raspberry-pi.bootloader = "kernel";
  hardware.raspberry-pi.config.all.base-dt-params = {
    pciex1 = { enable = true; value = "on"; };
    pciex1_gen = { enable = true; value = 3; };

    act_led_trigger = { enable = true; value = "none"; }; # green activity led behavior = off
    pwr_led_trigger = { enable = true; value = "none"; }; # red power led behavior = off
    eth_led0 = { enable = true; value = 4; }; # green led behavior = off
    eth_led1 = { enable = true; value = 8; }; # amber led behavior = link
  };
  nixpkgs.hostPlatform = "aarch64-linux";
}
