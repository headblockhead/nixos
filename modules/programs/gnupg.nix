{ pkgs, ... }:
{
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
  programs.git.config = {
    commit.gpgsign = true;
    gpg.program = "${pkgs.gnupg}/bin/gpg";
    tag.gpgsign = true;
  };
}
