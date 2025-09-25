{ lib, config, usernames, accountFromUsername, ... }:
{
  # Set user passwords.
  age.secrets = lib.genAttrs usernames
    (username:
      let
        account = accountFromUsername username;
      in
      {
        file = account.hashedPasswordAgeFile;
      }
    );
  users.users = lib.genAttrs usernames
    (username:
      let
        account = accountFromUsername username;
      in
      {
        description = account.realname;
        isNormalUser = true;
        extraGroups = (if account.trusted then [ "wheel" "dialout" ] else [ ]);
        hashedPasswordFile = config.age.secrets.${username}.path;
      }
    );

}
