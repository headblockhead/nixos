{ lib, accounts, ... }:
{
  systemd.services."serial-getty@ttyS0".enable = lib.mkDefault false;
  systemd.services."serial-getty@hvc0".enable = false;
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@".enable = false;
  boot.kernelParams = [
    "panic=1"
    "boot.panic_on_fail"
    "vga=0x317"
    "nomodeset"
  ];
  systemd.enableEmergencyMode = false;
  security.sudo.wheelNeedsPassword = false;
  users.users = (builtins.mapAttrs (n: v: { hashedPassword = "!"; }) accounts) // { root.hashedPassword = "!"; };
}
