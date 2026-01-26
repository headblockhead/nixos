{
  realname = "Edward Hesketh";
  email = "inbox@edwardh.dev";
  superuser = true;
  profileIcon = ./headb.png;
  # Keys that can be used to access machines as this user.
  sshkeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBexdKZYlyseEcm1S3xNDqPTGZMfm/NcW1ygY91weDhC cardno:30_797_561" # thunder-mountain
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIvDaJmOSXV24B83sIfZqAUurs+cZ7582L4QDePuc3p7 cardno:17_032_332" # depot-37
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICvr2FrC9i1bjoVzg+mdytOJ1P0KRtah/HeiMBuKD3DX cardno:23_836_181" # crystal-peak
  ];
  # The first GPG key is used for signing git commits.
  # Also update these in nixpkgs/maintainers/maintainer-list.nix
  gpgkeys = [
    "8E972E26D6D48C46" # thunder-mountain
    "672FFB8B28B17E09" # depot-37
    "AE25B4F5B6346CCF" # crystal-peak
  ];
}
