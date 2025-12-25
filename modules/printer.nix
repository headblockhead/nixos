{ pkgs, ... }: {
  hardware.printers = {
    ensurePrinters = [
      {
        name = "HP_Deskjet_2540";
        location = "Upstairs Office";
        deviceUri = "ipp://HP-Deskjet-2540/ipp/print";
        model = "HP/hp-deskjet_2540_series.ppd.gz";
        ppdOptions = {
          PageSize = "A4";
          ColorModel = "KGray";
          OutputMode = "Draft";
        };
      }
    ];
    ensureDefaultPrinter = "HP_Deskjet_2540";
  };
  services.printing = {
    enable = true;
    drivers = [ pkgs.hplip ];
  };
}
