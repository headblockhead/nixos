{
  config,
  lib,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  swapDevices = [
    {
      device = "/var/lib/swap";
      size = 8 * 1024;
      options = [ "discard" ];
    }
  ];

  boot.initrd.availableKernelModules = [
    "ahci"
    "ehci_pci"
    "sd_mod"
    "sr_mod"
    "xhci_pci"
  ];
  boot.kernelModules = [ "kvm-intel" ];

  nixpkgs.hostPlatform = "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
