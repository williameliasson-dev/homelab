# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Building and Testing
```bash
# Check flake syntax and dependencies
nix flake check

# Build the configuration without switching
nixos-rebuild build --flake .#lennart

# Test configuration in VM
nixos-rebuild build-vm --flake .#lennart

# Deploy to actual hardware (requires sudo)
sudo nixos-rebuild switch --flake .#lennart

# Enter development shell with required tools
nix develop
```

### Secret Management
```bash
# Edit encrypted secrets (requires agenix in development shell)
agenix -e secrets/wireguard-private.age

# Add new secrets by editing secrets.nix and creating the .age file
```

## Architecture Overview

This is a NixOS-based homelab configuration using:

- **Flake-based configuration** with both stable (24.05) and unstable nixpkgs channels
- **Modular service architecture** - each service in `modules/services/` is self-contained
- **Agenix secret management** for sensitive configuration data
- **Centralized storage** at `/mnt/storage` shared across media services

### Key Components

**Host Configuration** (`hosts/lennart/`):
- Main system configuration with users, networking, SSH hardening
- Hardware configuration (auto-generated)
- Imports all service modules via `modules/services/default.nix`

**Services** (`modules/services/`):
- `jellyfin.nix` - Media server with hardware acceleration
- `qbittorrent.nix` - Torrent client (custom systemd service)
- `blocky.nix` - DNS server with ad-blocking
- `wireguard.nix` - VPN server with client configs
- `homepage.nix` - Dashboard (runs as root override)
- `sftp.nix` - SFTP server with chroot
- `storage-setup.nix` - Storage directory initialization

### Service Patterns

**Standard Module Structure**: All services follow `{ config, lib, pkgs, ... }: { ... }`

**Firewall Management**: Each service manages its own ports via `networking.firewall`

**User Isolation**: Services run as dedicated system users with minimal permissions

**Storage Integration**: Media services share `/mnt/storage` with proper cross-service permissions

**Secret Management**: Encrypted files in `secrets/` directory, decrypted via agenix

### Network Configuration

- Internal network: Services communicate via `homelab.local` (192.168.0.109)
- VPN subnet: `10.100.0.0/24` via WireGuard
- Service ports: Jellyfin (8096), qBittorrent (8080), Blocky (53, 4000), Homepage (80)

### Security Considerations

- SSH key-only authentication, no passwords
- Service isolation via dedicated users/groups
- WireGuard VPN for secure remote access
- Agenix-encrypted secrets with proper file permissions
- Homepage runs as root (non-standard but intentional for this setup)

## System Information

- Target system: `lennart` (x86_64-linux)
- State version: 24.05
- Time zone: Europe/Stockholm
- Storage: Software RAID with mdadm