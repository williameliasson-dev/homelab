let
  # Your SSH public keys (add your actual public keys here)
  william = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHLhqTjuSrzwdJoVmJXQlcAXV+I0YJ9Fd/7Di+59sGb0 williameliasson5@gmail.com"; # Replace with your actual key

  # System SSH host keys (will be generated on the server)
  homelab = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF92aaEoSPS69P1B6CBLV6WCeQ/Mq3B5DDYDuJAp4pL+ homelab"; # Replace with server host key

  # All users who can decrypt secrets
  users = [ william ];

  # All systems that need to decrypt secrets
  systems = [ homelab ];

  # Both users and systems that can decrypt
  all = users ++ systems;
in
{
  # WireGuard secrets - only the homelab server needs these
  "secrets/wireguard-private.age".publicKeys = [
    william
    homelab
  ];

  # Example: other secrets that might be needed
  # "secrets/api-keys.age".publicKeys = all;
  # "secrets/passwords.age".publicKeys = all;
}
