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

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    ensureUsers = [{ name = "headb"; }];
  };

  environment.systemPackages = [
    pkgs.vscode
    pkgs.dotnetCorePackages.dotnet_8.sdk
    pkgs.gopass
    pkgs.openldap
  ];
}
