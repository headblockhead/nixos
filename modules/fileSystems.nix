{
  fileSystems = {
    "/" = {
      label = "nixos";
      fsType = "ext4";
    };
    "/boot" = {
      label = "boot";
      options = [ "fmask=0137" "dmask=0027" ];
      fsType = "vfat";
    };
  };
}
