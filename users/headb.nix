{ username, homeManagerModules, useCustomNixpkgsNixosModule, ... }:
{
  imports = with homeManagerModules; [
    useCustomNixpkgsNixosModule

    neovim
    zsh
  ];

  news.display = "silent";

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.05";
}
