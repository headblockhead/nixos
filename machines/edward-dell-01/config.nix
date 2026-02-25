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

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
  users.users.headb.extraGroups = [ "vboxusers" ];

  environment.systemPackages = [
    pkgs.dotnetCorePackages.dotnet_9.sdk
    pkgs.dotnet-sdk_9
    pkgs.vscode
    pkgs.gopass
    pkgs.openldap
    pkgs.jetbrains.rider
  ];

  environment.sessionVariables = {
    DOTNET_ROOT = "${pkgs.dotnet-sdk_9}/share/dotnet";
  };
}
