{
  fileSystems = {
    "/".label = "nixos";
    "/boot" = {
      label = "boot";
      options = [ "fmask=0137" "dmask=0027" ];
    };
  };
}
