# nixos

[![NixOS](https://img.shields.io/badge/NIXOS-5277C3.svg?logo=NixOS&logoColor=white)](https://nixos.org) [![xc compatible](https://xcfile.dev/badge.svg)](https://xcfile.dev) 

A continuously updated set of reproducible NixOS configurations for:
- a desktop and laptop
- a home network gateway/router
- a raspberry pi cluster
- a server running in AWS

## Structure

  * [accounts](accounts) contains definitions for details about users of these machines. 
  * [custom-packages](custom-packages) contains modified versions of existing nixpkgs packages.
  * [machines](machines) contains custom configuration for each machine.
  * [modules](modules) contains reusable configuration snippets that can be imported by multiple machines.
  * [secrets](secrets) contains age encrypted secrets used by some of my machines.

## Installation

### Medium

Obtain the latest minimal ISO image for your architecture, either from [nixos.org/download](https://nixos.org/download/) or by compiling it yourself.

You should be automatically logged in as the nixos user, from which you can use `sudo -i` to get a root shell, and begin the install.

### Wireless networking

> [!NOTE]
> If you already have a wired connection, you can skip this step.

Use `nmtui` for a TUI, or `wpa_cli` for a command-line style setup.

### Partition and format

> [!CAUTION]
> Check drive names carefully before committing changes to partition tables or initialising filesystems to make sure you aren't going to delete anything important!

To create partitions on the disk, I find `cfdisk` is a useful TUI tool.

```bash
cfdisk /dev/example
```

For an nvme drive, this would be something like `/dev/nvme0n1` (meaning nvme controller 0, namespace 1) here.

I'd recommend to delete all other partitions on the disk and create:

  - a 2G "EFI System" partition,
  - and a generic "Linux Filesystem" partition to fill the rest of the disk.

Format the new 'EFI System' partition with FAT 32, and label it `boot`:

```bash
mkfs.fat -F 32 -n boot /dev/example1
```
For an nvme drive, this would be something like `/dev/nvme0n1p1` (meaning nvme controller 0, namespace 1, partition 1) here.

Format the main 'Linux Filesystem' partition with ext4, and label it `nixos`:

```bash
mkfs.ext4 -L nixos /dev/example2
```
And again, for an nvme drive, this would be something like `/dev/nvme0n1p2`.

### Mount the new partitions

Mount the main `nixos` partition to `/mnt`:

```bash
mount /dev/example2 /mnt
```

Create a directory for the `boot` partition inside of the `nixos` partition, and then mount it there:

```bash
mkdir /mnt/boot
mount /dev/example1 /mnt/boot
```

### Install

Generate some example hardware configuration to reference.

```bash
nixos-generate-config --show-hardware-config > hardware-auto.nix
```

Clone a copy of this repo.

```bash
git clone https://knot.edwardh.dev/edwardh.dev/nixos.git
```

Compare the hardware-auto.nix file to the hardware.nix of the machine you intend to install, and update accordingly (imports, kernel modules, CPU microcode, etc.)

Make sure to also update the `system.stateVersion` to allign with the latest nixpkgs version you are using before installing.

Run the install command.
At the end, you will be asked to set a root password; you can make this anything as we will disable direct root access shortly after installing.

```bash
nixos-install --flake .#machine-name
```

Finally, reboot and remove your installation medium.

```bash
systemctl reboot
```

### Login

Use a TTY to login as root, then set a password for at least one superuser.

```bash
passwd headb
```

Logout of root, login as said superuser (either graphically or in a TTY), then delete the password for the root user and lock access to the root account.

```bash
sudo passwd -dl root
sudo usermod -L root
```

### Final setup

#### Gopass

Complete the first half of the setup form, then quit when reaching 'generating new key pair'.

```bash
gopass clone git@knot.edwardh.dev:edwardh.dev/gopass
```

#### GNOME theme for Firefox

source: [firefox-gnome-theme](https://github.com/rafaelmardojai/firefox-gnome-theme)

```bash
curl -s -o- https://raw.githubusercontent.com/rafaelmardojai/firefox-gnome-theme/master/scripts/install-by-curl.sh | bash
```

## Tasks

### switch

Switch to the new nixos configuration for the current machine.

```bash
sudo nixos-rebuild switch --flake .#
```

### boot

Set the new nixos configuration for the current machine as the default boot option.

```bash
sudo nixos-rebuild boot --flake .#
```

### deploy-test

Deploy the nixos configurations to servers, without setting the boot-default.

Env: NIX_SSHOPTS="-p 26"

```bash
nixos-rebuild test --target-host alpha.gateway.lan --sudo --no-reexec --flake .#gateway-alpha
nixos-rebuild test --target-host alpha.rpi4.lan --sudo --no-reexec --flake .#rpi4-alpha
nixos-rebuild test --target-host bravo.rpi4.lan --sudo --no-reexec --flake .#rpi4-bravo
nixos-rebuild test --target-host alpha.rpi5.lan --sudo --no-reexec --flake .#rpi5-alpha
nixos-rebuild test --target-host bravo.rpi5.lan --sudo --no-reexec --flake .#rpi5-bravo
nixos-rebuild test --target-host charlie.rpi5.lan --sudo --no-reexec --flake .#rpi5-charlie
nixos-rebuild test --target-host alpha.edwardh.dev --sudo --no-reexec --flake .#aws-alpha
```

### deploy-switch

Deploy the nixos configurations to servers, setting the boot-default.

Env: NIX_SSHOPTS="-p 26"

```bash
nixos-rebuild switch --target-host alpha.gateway.lan --sudo --no-reexec --flake .#gateway-alpha
nixos-rebuild switch --target-host alpha.rpi4.lan --sudo --no-reexec --flake .#rpi4-alpha
nixos-rebuild switch --target-host bravo.rpi4.lan --sudo --no-reexec --flake .#rpi4-bravo
nixos-rebuild switch --target-host alpha.rpi5.lan --sudo --no-reexec --flake .#rpi5-alpha
nixos-rebuild switch --target-host bravo.rpi5.lan --sudo --no-reexec --flake .#rpi5-bravo
nixos-rebuild switch --target-host charlie.rpi5.lan --sudo --no-reexec --flake .#rpi5-charlie
nixos-rebuild switch --target-host alpha.edwardh.dev --sudo --no-reexec --flake .#aws-alpha
```

### deploy-boot

Deploy the nixos configurations to servers, setting the boot-default.

Env: NIX_SSHOPTS="-p 26"

```bash
nixos-rebuild boot --target-host alpha.gateway.lan --sudo --no-reexec --flake .#gateway-alpha
nixos-rebuild boot --target-host alpha.rpi4.lan --sudo --no-reexec --flake .#rpi4-alpha
nixos-rebuild boot --target-host bravo.rpi4.lan --sudo --no-reexec --flake .#rpi4-bravo
nixos-rebuild boot --target-host alpha.rpi5.lan --sudo --no-reexec --flake .#rpi5-alpha
nixos-rebuild boot --target-host bravo.rpi5.lan --sudo --no-reexec --flake .#rpi5-bravo
nixos-rebuild boot --target-host charlie.rpi5.lan --sudo --no-reexec --flake .#rpi5-charlie
nixos-rebuild boot --target-host alpha.edwardh.dev --sudo --no-reexec --flake .#aws-alpha
```
### build

Build the nixos configurations for all machines, without deploying.

```bash
nixos-rebuild build --flake .#
nixos-rebuild build --flake .#gateway-alpha
nixos-rebuild build --flake .#rpi4-alpha
nixos-rebuild build --flake .#rpi4-bravo
nixos-rebuild build --flake .#rpi5-alpha
nixos-rebuild build --flake .#rpi5-bravo
nixos-rebuild build --flake .#rpi5-charlie
nixos-rebuild build --flake .#aws-alpha
```

### clean

Clean up servers.

```bash
ssh alpha.gateway.lan -p 26 sudo nix-collect-garbage -d --quiet
ssh alpha.rpi4.lan -p 26 sudo nix-collect-garbage -d --quiet
ssh bravo.rpi4.lan -p 26 sudo nix-collect-garbage -d --quiet
ssh alpha.rpi5.lan -p 26 sudo nix-collect-garbage -d --quiet
ssh bravo.rpi5.lan -p 26 sudo nix-collect-garbage -d --quiet
ssh charlie.rpi5.lan -p 26 sudo nix-collect-garbage -d --quiet
ssh alpha.edwardh.dev -p 26 sudo nix-collect-garbage -d --quiet
```

### reboot

Reboot servers.

```bash
ssh alpha.edwardh.dev -p 26 sudo systemctl reboot
ssh alpha.rpi4.lan -p 26 sudo systemctl reboot
ssh bravo.rpi4.lan -p 26 sudo systemctl reboot
ssh alpha.rpi5.lan -p 26 sudo systemctl reboot
ssh bravo.rpi5.lan -p 26 sudo systemctl reboot
ssh charlie.rpi5.lan -p 26 sudo systemctl reboot
ssh alpha.gateway.lan -p 26 sudo systemctl reboot
```
