{
  hardware.raspberry-pi.config = {
    all.base-dt-params = {
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
  };

  fileSystems."/" = {
    label = "NIXOS_SD";
    fsType = "ext4";
  };
  fileSystems."/boot/firmware" = {
    label = "FIRMWARE";
    options = [
      "fmask=0137"
      "dmask=0027"
    ];
    fsType = "vfat";
  };

  nixpkgs.hostPlatform = "aarch64-linux";
}
