{ config, lib, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "uas" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.kernelModules = [ "kvm-intel" ];

  networking.useDHCP = lib.mkDefault true;

  boot.initrd = {
    # Required to open the EFI partition and Yubikey
    kernelModules = [ "vfat" "nls_cp437" "nls_iso8859-1" "usbhid" ];
    luks = {
      yubikeySupport = true;
      devices."encrypted" = {
        device = "/dev/sda3";
        yubikey = {
          slot = 2;
          twoFactor = true;
          gracePeriod = 30; # Time in seconds to wait for Yubikey to be inserted
          keyLength = 64;
          saltLength = 16;
          storage = {
            device = "/dev/sda1";
            fsType = "vfat";
            path = "/crypt-storage/default";
          };
        };
      };
    };
  };


  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
