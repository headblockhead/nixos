{ pkgs, lib, accounts, ... }:
{
  # Default user shell is zsh.
  users.defaultUserShell = pkgs.zsh;

  systemd.tmpfiles.rules = lib.forEach accounts (account: "f /home/${account.username}/.zprofile");

  programs.command-not-found.enable = false;

  programs.zsh = {
    # Enable zsh as a shell, add it to the environment.
    enable = true;
    autosuggestions.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    ohMyZsh = {
      enable = true;
      plugins = [ "aws" "git" ];
    };
    interactiveShellInit = ''
      source ${../../custom.zsh-theme}
      export EDITOR='vim'
      source ${pkgs.zsh-nix-shell}/share/zsh-nix-shell/nix-shell.plugin.zsh
    '';
    shellAliases = {
      q = "exit";
      p = "gopass show -c -n";
      ls = "ls --color=tty -A";
    };
  };

  programs.fzf.keybindings = true;
  programs.fzf.fuzzyCompletion = true;
}
