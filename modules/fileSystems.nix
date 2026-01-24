{
  fileSystems = {
    "/".label = "nixos";
    "/boot" = {
      label = "boot";
      options = [ "fmask=0137" "dmask=0027" ];
    };
  };
  swapDevices = [
    {
      device = "/swap";
      size = 16 * 1024;
    }
  ];
}
