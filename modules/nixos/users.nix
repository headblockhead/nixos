{ account, ... }:
{
  users.users = {
    root.hashedPassword = "!"; # Disable root login
    ${account.username} = {
      description = account.realname;
      isNormalUser = true;
      extraGroups = [ "wheel" "dialout" ];
    };
  };
}
