{ pkgs, ... }:
{
  # Install fonts
  fonts.packages = [
    pkgs.nerd-fonts.sauce-code-pro
  ];

  services.kmscon = {
    enable = true;
    fonts = [{ name = "SauceCodePro Nerd Font"; package = pkgs.unstable.nerd-fonts.sauce-code-pro; }];
    extraConfig = ''font-size=12'';
    hwRender = false;
  };
}
