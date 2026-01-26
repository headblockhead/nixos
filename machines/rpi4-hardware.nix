{
  hardware.raspberry-pi.config = {
    all.base-dt-params = {
      act_led_trigger = { enable = true; value = "none"; }; # green activity led behavior = off
      pwr_led_trigger = { enable = true; value = "none"; }; # red power led behavior = off
      eth_led0 = { enable = true; value = 4; }; # green led behavior = off
      eth_led1 = { enable = true; value = 8; }; # amber led behavior = link
    };
  };

  fileSystems."/".label = "NIXOS_SD";
  fileSystems."/boot/firmware" = {
    label = "FIRMWARE";
    options = [ "fmask=0137" "dmask=0027" ];
  };

  nixpkgs.hostPlatform = "aarch64-linux";
}
