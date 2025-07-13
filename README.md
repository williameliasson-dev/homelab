# Homelab NixOS Configuration

A declarative NixOS configuration for your homelab setup.

## Structure

```
.
├── flake.nix                    # Main flake configuration
├── hosts/
│   └── homelab/
│       ├── configuration.nix   # Main system configuration
│       └── hardware-configuration.nix  # Hardware-specific config (generated)
└── modules/
    └── services/
        ├── default.nix         # Service imports
        ├── jellyfin.nix        # Media server
        ├── dns.nix             # DNS/Pi-hole replacement
        ├── wireguard.nix       # VPN configuration
        └── storage.nix         # Storage/SFTP configuration
```

## Usage

1. Generate hardware configuration:
   ```bash
   nixos-generate-config --root /mnt --dir ./hosts/homelab/
   ```

2. Build the configuration:
   ```bash
   nix flake check
   ```

3. Test in a VM:
   ```bash
   nixos-rebuild build-vm --flake .#homelab
   ```

4. Deploy to actual hardware:
   ```bash
   sudo nixos-rebuild switch --flake .#homelab
   ```

## Services

Service modules are located in `modules/services/` and can be enabled/configured individually.