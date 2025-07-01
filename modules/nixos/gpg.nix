{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    gnupg
  ];

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gnome3;
    enableSSHSupport = true;
  };
}
