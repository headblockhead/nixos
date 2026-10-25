{ lib, reverseDomainName, ... }:
let
  # Computer specific keys:
  edward-desktop-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOs2G2Yt7+A53v5tymBcbAlWnT9tLZYNSW+XGqZU6ITh";
  edward-laptop-key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMut/MMjt9kH1+YuBLLZ0GcJ1rToFZObggpnyDEnRi7L";

  buildMachines = [
    {
      hostName = "desktop.edward.lan:26";
      systems = [ "x86_64-linux" ];
      sshUser = "nixbuilder";
      sshKey = "/etc/ssh/ssh_host_ed25519_key";
      protocol = "ssh-ng";
      # base64 -w0
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSU9zMkcyWXQ3K0E1M3Y1dHltQmNiQWxXblQ5dExaWU5TVytYR3FaVTZJVGg=";
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
        "kvm"
      ];
      mandatoryFeatures = [ ];
      maxJobs = 8;
      speedFactor = 10;
    }
    {
      hostName = "alpha.rpi5.lan:26";
      systems = [ "aarch64-linux" ];
      sshUser = "nixbuilder";
      sshKey = "/etc/ssh/ssh_host_ed25519_key";
      protocol = "ssh-ng";
      # base64 -w0
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUtEbVpOb0VRVHpXczFUZzhyTFhwb29hUCtlSnR0QnNqemIrMWtLNlRLdVIK";
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
      ];
      mandatoryFeatures = [ ];
      maxJobs = 4;
      speedFactor = 3;
    }
    {
      hostName = "bravo.rpi5.lan:26";
      systems = [ "aarch64-linux" ];
      sshUser = "nixbuilder";
      sshKey = "/etc/ssh/ssh_host_ed25519_key";
      protocol = "ssh-ng";
      # base64 -w0
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUhSMWVsZzhGL1BzMk9QMDdzb2xBa2ZMRnVwYVFZSzRDMUhsTitjZk52UXIK";
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
      ];
      mandatoryFeatures = [ ];
      maxJobs = 4;
      speedFactor = 3;
    }
    {
      hostName = "charlie.rpi5.lan:26";
      systems = [ "aarch64-linux" ];
      sshUser = "nixbuilder";
      sshKey = "/etc/ssh/ssh_host_ed25519_key";
      protocol = "ssh-ng";
      # base64 -w0
      publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUUxMkxkVDVDVUl5ZXlHQy9LcjZIUEFTOUt6UXRKNEhFRDlLWVlDdlhVUmIK";
      supportedFeatures = [
        "nixos-test"
        "benchmark"
        "big-parallel"
      ];
      mandatoryFeatures = [ ];
      maxJobs = 4;
      speedFactor = 3;
    }
  ];
in
{
  # Exclude ourself from the buildMachines list.
  nix.buildMachines = lib.lists.remove (lib.lists.findFirst (
    m:
    m.hostName == (
      (lib.concatStringsSep "." (lib.reverseList (lib.splitString "." reverseDomainName))) + ".lan:26"
    )
  ) { } buildMachines) buildMachines;

  nix.settings.trusted-users = [ "nixbuilder" ];
  users.users.nixbuilder = {
    isNormalUser = true;
    extraGroups = [
      "libvirt"
      "nixbld"
    ];
    openssh.authorizedKeys.keys = [
      edward-desktop-key
      edward-laptop-key
    ];
  };
  nix.distributedBuilds = true;
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';
}
