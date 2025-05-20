{ pkgs, ... }: {
  # GnuPG and smart card pinentry tools.
  environment.systemPackages = with pkgs; [
    gnupg
    gopass
  ];

  # Smart card daemon.
  services.pcscd.enable = true;

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };
}
