{ lib, config, usernames, accountFromUsername, ... }:
{
  age.secrets = lib.genAttrs usernames (username: { file = (accountFromUsername username).hashedPasswordAgeFile; });
  users.users = lib.genAttrs usernames (username: { hashedPasswordFile = config.age.secrets.${username}.path; });
}
