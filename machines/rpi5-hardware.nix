{ inputs, ... }:
{
  boot.kernelParams = [ "pcie_aspm=off" ];
  imports = [
    inputs.nixos-raspberrypi.lib.inject-overlays
    inputs.nixos-raspberrypi.nixosModules.raspberry-pi-5.base
  ];
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

    #    hdmi = {
    #enable = true;
    #value = "off";
    #};
    #sd = {
    #enable = true;
    #value = "off";
    #};
    #uart0 = {
    #enable = true;
    #value = "off";
    #};
    #uart1 = {
    #enable = true;
    #value = "off";
    #};

    act_led_trigger = {
      # green led behavior = heartbeat
      enable = true;
      value = "heartbeat";
    };
    pwr_led_trigger = {
      # red led behavior = on
      enable = true;
      value = "on";
    };

    eth_led0 = {
      # green ethernet led behavior = link
      enable = true;
      value = 8;
    };
    eth_led1 = {
      # amber ethernet led behavior = activity
      enable = true;
      value = 9;
    };
  };
  nixpkgs.hostPlatform = "aarch64-linux";
}
