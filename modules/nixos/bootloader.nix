{
  boot = {
    consoleLogLevel = 0;
    kernelParams = [
      "quiet"
      "splash"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
      "amdgpu.seamless=1"
      "amdgpu.freesync_video=1"
      "plymouth.use-simpledrm"
    ];
    initrd = {
      verbose = false;
      systemd = true;
    };
    loader = {
      timeout = 0;
      efi = {
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot";
      };
      systemd-boot.enable = true;
    };
    plymouth.enable = true;
  };
}
