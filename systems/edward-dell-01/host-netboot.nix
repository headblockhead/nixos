{ netbooted-system, ... }:
{
  services.pixiecore = {
    enable = true;
    openFirewall = true;
    dhcpNoBind = true; # Use existing DHCP server.

    mode = "boot";
    kernel = "${netbooted-system.kernel}/bzImage";
    initrd = "${netbooted-system.netbootRamdisk}/initrd";
    cmdLine = "init=${netbooted-system.toplevel}/init loglevel=4";
    debug = true;
  };

}
