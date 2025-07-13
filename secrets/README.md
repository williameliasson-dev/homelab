# Encrypted Secrets

This directory contains encrypted secrets managed by agenix.

## Setup Instructions

1. **Update .agenix with your actual SSH keys**:
   - Replace the placeholder SSH keys in `.agenix` with your actual public keys
   - Get your SSH public key: `cat ~/.ssh/id_ed25519.pub`
   - Get server host key after first boot: `cat /etc/ssh/ssh_host_ed25519_key.pub`

2. **Generate WireGuard keys**:
   ```bash
   # Generate server private key
   wg genkey
   
   # Generate client keys
   wg genkey | tee client_private.key | wg pubkey > client_public.key
   ```

3. **Create encrypted secret files**:
   ```bash
   # Enter development shell with agenix CLI
   nix develop
   
   # Create encrypted WireGuard private key
   agenix -e secrets/wireguard-private.age
   # Paste the WireGuard server private key and save
   ```

4. **Update WireGuard config**:
   - Replace `CLIENT_PUBLIC_KEY_HERE` in `modules/services/wireguard.nix` with actual client public keys

## Files

- `wireguard-private.age` - Encrypted WireGuard server private key
- `README.md` - This file (not encrypted)

## Security Notes

- The `.age` files are encrypted and safe to commit to git
- Never commit unencrypted private keys
- The .agenix file defines who can decrypt each secret