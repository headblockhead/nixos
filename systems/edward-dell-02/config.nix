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

  environment.systemPackages = [
    pkgs.openldap
  ];
}
