{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gh
    difftastic
  ];
  programs.git = {
    enable = true;
    prompt.enable = true;
    config = {
      diff.external = "${pkgs.difftastic}/bin/difft --color auto --background dark --display inline";
      init.defaultBranch = "master";
      commit.gpgsign = true;
      gpg.program = "${pkgs.gnupg}/bin/gpg";
      pull.rebase = false;
      tag.gpgsign = true;
      user = {
        email = "inbox@edwardh.dev";
        name = "Edward Hesketh";
        signingkey = "76C6E96B6A561DBE8F92B2E1AE25B4F5B6346CCF";
      };
      "crendential \"https://github.com\"" = {
        helper = "${pkgs.gh}/bin/gh auth git-credential";
      };
      "credential \"https://gist.github.com\"" = {
        helper = "${pkgs.gh}/bin/gh auth git-credential";
      };
    };
  };
}
