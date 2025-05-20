{ config, outputs, netboot-client, ... }:

{
  networking.hostName = "edward-dell-01";

  imports = with outputs.nixosModules; [
    basicConfig
    bluetooth
    bootloaderGraphical
    desktop
    desktopApps
    fileSystems
    fonts
    fzf
    git
    gpg
    homeManager
    network
    sound
    ssh
    ssd
    users
    zsh
  ];

  age.secrets.wg1-edward-dell-01-key.file = ../../secrets/wg1-edward-dell-01-key.age;
  age.secrets.wg1-edward-dell-01-preshared-key.file = ../../secrets/wg1-edward-dell-01-preshared-key.age;
  age.secrets.wg2-edward-dell-01-key.file = ../../secrets/wg2-edward-dell-01-key.age;
  age.secrets.wg2-edward-dell-01-preshared-key.file = ../../secrets/wg2-edward-dell-01-preshared-key.age;



  networking.wireguard = {
    enable = false;
    interfaces = {
      wg1 = {
        ips = [ "172.16.11.11/24" ];
        listenPort = 51801;
        privateKeyFile = config.age.secrets.wg1-edward-dell-01-key.path;
        peers = [
          {
            name = "edwardh";
            publicKey = "N+Zy+x/CG3CW78b3+7JqQTIYy7jSURjugKhPjJjDW2M=";
            presharedKeyFile = config.age.secrets.wg1-edward-dell-01-preshared-key.path;
            endpoint = "18.135.222.143:51801";

            allowedIPs = [ "172.16.0.0/16" ];
            persistentKeepalive = 25;
          }
        ];
      };
      wg2 = {
        ips = [ "172.16.12.11/24" ];
        listenPort = 51802;
        privateKeyFile = config.age.secrets.wg2-edward-dell-01-key.path;
        peers = [
          {
            name = "edwardh";
            publicKey = "GccFAvCqia8Q5yK45FOb3zROp7bdtz9NLBoqDRoif2I=";
            presharedKeyFile = config.age.secrets.wg2-edward-dell-01-preshared-key.path;
            endpoint = "18.135.222.143:51802";

            allowedIPs = [ "0.0.0.0/0" ];
            persistentKeepalive = 25;
          }
        ];
      };
    };
  };

  services.pixiecore = {
    enable = true;
    openFirewall = true;
    dhcpNoBind = true; # Use existing DHCP server.

    mode = "boot";
    kernel = "${netboot-client.kernel}/bzImage";
    initrd = "${netboot-client.netbootRamdisk}/initrd";
    cmdLine = "init=${netboot-client.toplevel}/init loglevel=4";
    debug = true;
  };

  programs.ssh = {
    # Redirect SSH connections to GitHub to port 443, to get around firewall.
    extraConfig = ''
      Host github.com
        Hostname ssh.github.com
        Port 443
        User git
    '';
  };

  # find / -name '*.desktop' 2> /dev/null
  services.xserver.desktopManager.gnome.favoriteAppsOverride = ''
    [org.gnome.shell]
    favorite-apps=[ 'firefox.desktop', 'org.gnome.Terminal.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Settings.desktop', 'org.gnome.Calculator.desktop', 'org.freecad.FreeCAD.desktop', 'org.kicad.kicad.desktop', 'gnome-system-monitor.desktop', 'thunderbird.desktop', 'slack.desktop', 'spotify.desktop']
  '';

  environment.systemPackages = [
  ];

  system.stateVersion = "22.05";
}
