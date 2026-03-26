{ pkgs, ... }:
{
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
  networking.firewall.allowedTCPPorts = [ 64023 50051 ];

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  services.postgresql = {
    enable = true;
    package = pkgs.postgresql_16;
    ensureUsers = [{ name = "headb"; }];
    settings.max_wal_size = "30GB";
  };

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
  hardware.rtl-sdr.enable = true;
  users.users.headb.extraGroups = [ "vboxusers" "plugdev" ];

  programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhsWithPackages (ps: with ps; [ dotnetCorePackages.dotnet_10.sdk dotnet-sdk_10 ]);
  };

  environment.systemPackages = [
    pkgs.cubicsdr
    pkgs.blender-hip
    pkgs.kdePackages.kdenlive
    pkgs.prismlauncher
    pkgs.clonehero
    pkgs.jetbrains.rider
  ];
}
