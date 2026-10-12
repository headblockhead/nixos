let
  edwardh = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOlOFRdX4CqbBfeikQKXibVIxhFjg0gTcTUdTgDIL7H8";
in
{
  "mail-hashed-password.age".publicKeys = [ edwardh ];
  "radicale-htpasswd.age".publicKeys = [ edwardh ];
  "tranquil-pds.age".publicKeys = [ edwardh ];
  "knot-rs.age".publicKeys = [ edwardh ];
}
