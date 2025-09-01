{ lib, usernames, accountFromUsername, ... }:
{
  users.users = lib.genAttrs usernames
    (username:
      let
        account = accountFromUsername username;
      in
      {
        description = account.realname;
        isNormalUser = true;
        extraGroups = (if account.trusted then [ "wheel" "dialout" ] else [ ]);
      }
    );
}
