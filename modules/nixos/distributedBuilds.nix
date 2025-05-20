{ config, lib, ... }:
let
  # Computer specific keys:
  gateway-key = ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFl5CJU+QEKdSV/ybMegoKGT+NamF1FBYcMcSRACZLvJ'';
  edward-desktop-01-key = ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOs2G2Yt7+A53v5tymBcbAlWnT9tLZYNSW+XGqZU6ITh'';
  edward-laptop-01-key = ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDGOkGgaa7J85LK4Vfe3+NvxxQObZspyRd50OkUQz/Ox'';
  rpi5-01-key = ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKtvhxOROlavY2jNZUgpD1BkTgDNavy/TuoLnDyGWxlV'';
  rpi5-03-key = ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ/4Qh6r7a065byYqI9gEba44DRXDuUF6vbIUduk/EJF'';
  printerpi-key = ''ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIO1ULDVHDscwoicWFYgNPumTF2l5clw6Nh6hr9tdLDll'';

  buildMachines = [
    {
      hostName = "edward-desktop-01";
      systems = [ "x86_64-linux" ];
      sshUser = "nixbuilder";
      sshKey = "/etc/ssh/ssh_host_ed25519_key";
      protocol = "ssh-ng";
      # base64 -w0
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU9zMkcyWXQ3K0E1M3Y1dHltQmNiQWxXblQ5dExaWU5TVytYR3FaVTZJVGg=";
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      mandatoryFeatures = [ ];
      maxJobs = 8;
      speedFactor = 10;
    }
    {
      hostName = "rpi5-01";
      systems = [ "aarch64-linux" ];
      sshUser = "nixbuilder";
      sshKey = "/etc/ssh/ssh_host_ed25519_key";
      protocol = "ssh-ng";
      # base64 -w0
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUt0dmh4T1JPbGF2WTJqTlpVZ3BEMUJrVGdETmF2eS9UdW9MbkR5R1d4bFYK";
      supportedFeatures = [ "nixos-test" ];
      mandatoryFeatures = [ ];
      maxJobs = 4;
      speedFactor = 3;
    }
    {
      hostName = "rpi5-03";
      systems = [ "aarch64-linux" ];
      sshUser = "nixbuilder";
      sshKey = "/etc/ssh/ssh_host_ed25519_key";
      protocol = "ssh-ng";
      # base64 -w0
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUovNFFoNnI3YTA2NWJ5WXFJOWdFYmE0NERSWER1VUY2dmJJVWR1ay9FSkY=";
      supportedFeatures = [ "nixos-test" ];
      mandatoryFeatures = [ ];
      maxJobs = 4;
      speedFactor = 3;
    }
  ];
in
{
  # Exclude ourself from the buildMachines list.
  nix.buildMachines = lib.lists.remove (lib.lists.findFirst (m: m.hostName == config.networking.hostName) { } buildMachines) buildMachines;

  nix.settings.trusted-users = [ "nixbuilder" ];
  users.users.nixbuilder = {
    isNormalUser = true;
    extraGroups = [ "libvirt" "nixbld" ];
    openssh.authorizedKeys.keys = [
      gateway-key
      edward-desktop-01-key
      printerpi-key
      edward-laptop-01-key
      rpi5-01-key
      rpi5-03-key
    ];
  };
  nix.distributedBuilds = true;
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';
}
