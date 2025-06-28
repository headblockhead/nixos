{ account, ... }: {
  programs.zsh = {
    enable = true;
    initContent = ''
      export ZSH_HIGHLIGHT_STYLES[comment]=fg=245,bold
      export DEFAULT_USER=${account.username}
    '';
  };
}
