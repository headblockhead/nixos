{ pkgs, ... }:
{
  security.sudo.wheelNeedsPassword = false;

  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      workstation = true;
    };
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

  environment.systemPackages = with pkgs; [
    openldap
    adcli # Helper library and tools for Active Directory client operations
    realmd # Diagnostic command; Does not configure AD client on NixOS
    samba # Standard Windows interoperability suite of programs for Linux and Unix
  ];
}
