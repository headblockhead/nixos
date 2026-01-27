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

### Wireless networking with wpa_supplicant

> [!NOTE]
> If you already have a wired connection, you can skip this step.

To connect to a standard wireless network, you can use wpa_supplicant as follows:

```bash
systemctl start wpa_supplicant
wpa_cli
> add_network
> set_network 0 ssid "your_ssid_here"
> set_network 0 psk "your_password_here"
> enable_network 0
> save_config
> quit
```

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

The instructions for formatting below apply to this partition scheme.

> [!TIP]
> If you are doing something different and you want to use my [modules/fileSystems.nix](modules/fileSystems.nix) file unedited, it is important you use the partition labels `boot` and `nixos` so the system can find them on boot.

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
git clone https://github.com/headblockhead/nixos.git
```

Compare the hardware-auto.nix file to the hardware.nix of the machine you intend to install, and update accordingly (imports, kernel modules, CPU microcode, etc.)

Run the install command.
At the end, you will be asked to set a root password; you can make this anything as we will disable direct root access shortly.

```bash
nixos-install --flake .#machine-name
```

Finally, reboot.

```bash
systemctl reboot
```

### Login

Use a TTY shell to login as root, then set a password for at least one superuser.

```bash
passwd headb
```

Logout of root, login as said superuser, then delete the password for the root user and lock access to the root account.

```bash
sudo passwd -dl root
sudo usermod -L root
```

### Extras

Useful little bits for polishing the system.

#### GNOME theme for Firefox

source: [firefox-gnome-theme](https://github.com/rafaelmardojai/firefox-gnome-theme)

```bash
curl -s -o- https://raw.githubusercontent.com/rafaelmardojai/firefox-gnome-theme/master/scripts/install-by-curl.sh | bash
```

#### Gopass

Complete the first half of the setup form, then quit when reaching 'generating new key pair'.

```bash
gopass clone git@github.com:headblockhead/gopass
```

## Tasks

### nixos

Switch to the new nixos configuration.

```bash
sudo nixos-rebuild switch --flake .#
```

### test-deploy

Deploy the nixos configurations to all machines, without setting the boot-default.

```bash
nixos-rebuild test --target-host gateway --sudo --no-reexec --flake .#gateway
nixos-rebuild test --target-host rpi4-01 --sudo --no-reexec --flake .#rpi4-01
nixos-rebuild test --target-host rpi4-02 --sudo --no-reexec --flake .#rpi4-02
nixos-rebuild test --target-host rpi5-01 --sudo --no-reexec --flake .#rpi5-01
nixos-rebuild test --target-host rpi5-02 --sudo --no-reexec --flake .#rpi5-02
nixos-rebuild test --target-host rpi5-03 --sudo --no-reexec --flake .#rpi5-03
nixos-rebuild test --target-host edwardh.dev --sudo --no-reexec --flake .#edwardh
```

### rollout

Deploy the nixos configurations to all machines, setting the boot-default.

```bash
nixos-rebuild switch --target-host gateway --sudo --no-reexec --flake .#gateway
nixos-rebuild switch --target-host rpi4-01 --sudo --no-reexec --flake .#rpi4-01
nixos-rebuild switch --target-host rpi4-02 --sudo --no-reexec --flake .#rpi4-02
nixos-rebuild switch --target-host rpi5-01 --sudo --no-reexec --flake .#rpi5-01
nixos-rebuild switch --target-host rpi5-02 --sudo --no-reexec --flake .#rpi5-02
nixos-rebuild switch --target-host rpi5-03 --sudo --no-reexec --flake .#rpi5-03
nixos-rebuild switch --target-host edwardh.dev --sudo --no-reexec --flake .#edwardh
```

### build

Build the nixos configurations for all machines, without deploying.

```bash
nixos-rebuild build --flake .#gateway
nixos-rebuild build --flake .#rpi4-01
nixos-rebuild build --flake .#rpi4-02
nixos-rebuild build --flake .#rpi5-01
nixos-rebuild build --flake .#rpi5-02
nixos-rebuild build --flake .#rpi5-03
nixos-rebuild build --flake .#edwardh
```
