{ lib, ... }: {
  users.mutableUsers = lib.mkForce true;
  users.users.root.hashedPassword = lib.mkForce null;
  users.users.root.password = lib.mkForce "root";
}
