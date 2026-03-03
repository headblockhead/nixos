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
  #virtualisation.virtualbox.host.enableExtensionPack = true;
  users.users.headb.extraGroups = [ "vboxusers" ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhsWithPackages (ps: with ps; [ dotnetCorePackages.dotnet_10.sdk dotnet-sdk_10 ]);
  };

  environment.systemPackages = [
    pkgs.dotnetCorePackages.dotnet_10.sdk
    pkgs.dotnet-sdk_10
    pkgs.gopass
    pkgs.openldap
    pkgs.jetbrains.rider
  ];

  environment.sessionVariables = {
    DOTNET_ROOT = "${pkgs.dotnet-sdk_10}/share/dotnet";
  };
}
