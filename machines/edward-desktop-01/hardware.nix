{ config, lib, pkgs, modulesPath, accounts, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "uas" "sd_mod" ];
  boot.kernelModules = [ "kvm-amd" ];

  environment.systemPackages = with pkgs; [
    clinfo
    lact
  ];

  systemd.packages = with pkgs; [ lact ];
  systemd.services.lactd.wantedBy = [ "multi-user.target" ];

  hardware.amdgpu = {
    initrd.enable = true;
    opencl.enable = true;
  };

  # Monitor setup
  boot.plymouth.extraConfig = ''
    DeviceScale=2
  '';
  services.kmscon.extraConfig = lib.mkAfter ''
    font-dpi=192
  '';
  systemd.tmpfiles.rules = [
    ''L+ /run/gdm/.config/monitors.xml - - - - ${./monitors.xml}''
  ] ++ builtins.attrValues (builtins.mapAttrs (n: v: "L+ /home/${n}/.config/monitors.xml - - - - ${./monitors.xml}") accounts);
  boot.kernelParams = [ "video=HDMI-A-2:panel_orientation=left_side_up" ];

  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
