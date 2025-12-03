{ pkgs, ... }:
{
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
    favorite-apps=[ 'firefox.desktop', 'org.gnome.Ptyxis.desktop', 'org.gnome.Nautilus.desktop', 'org.gnome.Settings.desktop', 'org.gnome.Calculator.desktop', 'org.freecad.FreeCAD.desktop', 'org.kicad.kicad.desktop', 'org.gnome.SystemMonitor.desktop', 'thunderbird.desktop', 'slack.desktop', 'spotify.desktop']
  '';

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    ensureUsers = [{ name = "headb"; }];
  };

  environment.systemPackages = [
    pkgs.vscode
    pkgs.gopass
    pkgs.openldap
  ];
}
