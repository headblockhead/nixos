let
  keys = {
    aws.alpha = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOlOFRdX4CqbBfeikQKXibVIxhFjg0gTcTUdTgDIL7H8";
    gateway.alpha = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOh5SMZFuDFcQiA4d9eR1L7NRCzh7CC1LKewLORvTcYe";
    rpi5 = {
      alpha = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKDmZNoEQTzWs1Tg8rLXpooaP+eJttBsjzb+1kK6TKuR";
      bravo = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHR1elg8F/Ps2OP07solAkfLFupaQYK4C1HlN+cfNvQr";
      charlie = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE12LdT5CUIyeyGC/Kr6HPAS9KzQtJ4HED9KYYCvXURb";
    };
  };
in
{
  "aws.alpha.mail.age".publicKeys = [ keys.aws.alpha ];
  "aws.alpha.radicale.age".publicKeys = [ keys.aws.alpha ];

  "rpi5.alpha.tranquil.age".publicKeys = [ keys.rpi5.alpha ];
  "rpi5.alpha.knot.age".publicKeys = [ keys.rpi5.alpha ];

  "rpi5.alpha.radicle.age".publicKeys = [ keys.rpi5.alpha ];
  "rpi5.bravo.radicle.age".publicKeys = [ keys.rpi5.bravo ];
  "rpi5.charlie.radicle.age".publicKeys = [ keys.rpi5.charlie ];

  "gateway.alpha.wg.age".publicKeys = [ keys.gateway.alpha ];
  "aws.alpha.wg.age".publicKeys = [ keys.aws.alpha ];
}
