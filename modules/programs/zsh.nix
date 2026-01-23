{ accounts, pkgs, ... }:
{
  systemd.tmpfiles.rules = builtins.attrValues (builtins.mapAttrs (n: v: "f /home/${n}/.zprofile") accounts);

  # TODO: allow for choice
  users.defaultUserShell = pkgs.zsh;

  programs.zsh = {
    enable = true;
    histSize = 10000;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "aws" "git" ];
    };
    interactiveShellInit = ''
      source ${./custom.zsh-theme}
    '';
    shellAliases = {
      q = "exit";
      p = "gopass show -c -n";
      ls = "ls --color=tty -A";
    };
  };
}
