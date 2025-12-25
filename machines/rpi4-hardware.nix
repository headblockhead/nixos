{
  hardware.raspberry-pi.config = {
    all.base-dt-params = {
      act_led_trigger = { enable = true; value = "none"; }; # green activity led behavior = off
      pwr_led_trigger = { enable = true; value = "none"; }; # red power led behavior = off
      eth_led0 = { enable = true; value = 4; }; # green led behavior = off
      eth_led1 = { enable = true; value = 8; }; # amber led behavior = link
    };
  };

  fileSystems."/" =
    {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };

  fileSystems."/boot/firmware" =
    {
      options = [ "fmask=0137" "dmask=0027" ];
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
    };
}
