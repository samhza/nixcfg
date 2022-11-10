let
  sam = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJHuLxp26yYiaPIz07V4X7a9N+PinBUGsnnVutZSpFaL";
  users = [ sam ];

  lilith = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHxZegC15ua0LbQ5Ut6mM++OUL6aq9WHx+JnqqJRDcwI";
  systems = [ lilith ];
in
{
  "esammy.toml.age".publicKeys = [sam lilith];
  "spotify-password.age".publicKeys = [sam lilith];
  "wireguard-key-lilith.age".publicKeys = [sam lilith];
}
