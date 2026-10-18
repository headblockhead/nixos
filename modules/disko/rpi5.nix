{ inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
  ];

  disko.devices = {
    disk = {
      nvme = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            firmware = {
              label = "firmware";
              type = "0700";
              size = "2048M";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot/firmware";
                mountOptions = [ "umask=0077" ];
              };
            };
            luks = {
              label = "luks";
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                enrollFido2 = true;
                extraFido2EnrollArgs = [
                  "--fido2-with-user-presence=true"
                  "--fido2-with-user-verification=false"
                  "--fido2-credential-algorithm=eddsa"
                ];
                enrollRecovery = false;
                content = {
                  type = "btrfs";
                  subvolumes = {
                    "/nix" = {
                      mountOptions = [ "compress=zstd" ];
                      mountpoint = "/nix";
                    };
                    "/persist" = {
                      mountOptions = [ "compress=zstd" ];
                      mountpoint = "/persist";
                    };
                    "/var/lib/swap" = {
                      mountpoint = "/var/lib/swap";
                      swap = {
                        swapfile.size = "16G";
                      };
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
    nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = [ "size=50%" ];
      };
    };
  };
}
