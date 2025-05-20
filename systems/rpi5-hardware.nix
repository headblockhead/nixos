{
  hardware.raspberry-pi.config = {
    all.base-dt-params = {
      nvme = {
        enable = true;
        value = "on";
      };
      pciex1_gen = {
        enable = true;
        value = 3;
      };
    };
  };
}
