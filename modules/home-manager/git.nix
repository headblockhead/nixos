{ account, ... }:
{
  programs.git = {
    enable = true;
    userName = account.realname;
    userEmail = account.email;
    signing = {
      key = builtins.head account.gpgkeys;
    };
  };
}
