{ config, lib, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.kernelModules = [ "kvm-intel" ];

  security.tpm2.enable = lib.mkForce false;
  boot.initrd.systemd.tpm2.enable = lib.mkForce false;

  # Fix hardware sound issue
  boot.extraModprobeConfig = ''
    options snd_hda_intel power_save=0
  '';

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
