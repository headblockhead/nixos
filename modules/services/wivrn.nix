{ pkgs, accounts, ... }:
{
  services.wivrn = {
    enable = true;
    steam = {
      enable = true;
      importOXRRuntimes = true;
    };
    highPriority = true;
  };

  environment.systemPackages = [
    pkgs.android-tools
  ];

  users.users = builtins.mapAttrs (n: v: {
    extraGroups = (if v.superuser then [ "adbusers" ] else [ ]);
  }) accounts;
}
