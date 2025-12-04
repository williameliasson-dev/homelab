let
  # Your SSH public keys (add your actual public keys here)
  william = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGLHJ09aA0rj9RkI7XjzK51hGNV2/nnANikt7f5aSLZP williameliasson5@gmail.com"; # Replace with your actual key

  # System SSH host keys (will be generated on the server)
  homelab = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBqwyQ/dRkEHsDUQn2UIDxqFiIS3JFHlA+Pv1rdlkI0v root@homelab"; # Replace with server host key

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

  # Vaultwarden environment variables (admin token, SMTP, etc.)
  "secrets/vaultwarden-env.age".publicKeys = [
    william
    homelab
  ];

  # CouchDB admin credentials for Obsidian LiveSync
  "secrets/couchdb-admin.age".publicKeys = [
    william
    homelab
  ];

  # Example: other secrets that might be needed
  # "secrets/api-keys.age".publicKeys = all;
  # "secrets/passwords.age".publicKeys = all;
}
