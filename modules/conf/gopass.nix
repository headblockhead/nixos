{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gopass
  ];
  programs.zsh.shellAliases.p = "gopass show -c -n";
}
