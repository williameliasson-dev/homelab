{
  config,
  pkgs,
  lib,
  nixpkgs-stable,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/services
  ];

  system.stateVersion = "24.05";

  # Boot configuration
  boot = {
    loader = {
      grub = {
        enable = true;
        efiSupport = true;
        device = "nodev";
        efiInstallAsRemovable = true; # This helps with older BIOS
      };
      efi.canTouchEfiVariables = false;
    };
    swraid = {
      enable = true;
      mdadmConf = ''
        MAILADDR root
        PROGRAM /run/current-system/sw/bin/logger
      '';
    };
  };

  # Networking
  networking = {
    hostName = "homelab";
    networkmanager.enable = true;
    firewall = {
      enable = true;
      # Ports will be opened by individual services
    };
  };

  # Users
  users.users.homelab = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGLHJ09aA0rj9RkI7XjzK51hGNV2/nnANikt7f5aSLZP williameliasson5@gmail.com"
    ];
  };

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # System packages
  environment.systemPackages = with pkgs; [
    git
    htop
    tmux
    curl
    wget
    vim
    tree
  ];

  # Enable flakes
  nix = {
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };

  # Time zone
  time.timeZone = "Europe/Stockholm";

  # Auto-rebuild on git updates
  services.auto-rebuild = {
    enable = true;
    interval = "*/1 * * * *"; # Every 1 minutes
    repoPath = "/etc/nixos";
    flakePath = "/etc/nixos";
    hostName = "lennart";
  };

  # NFS Server
  services.nfs-server = {
    enable = true;
    exports = ''
      # Export storage to local network (192.168.0.0/24)
      /mnt/storage 192.168.0.0/24(rw,sync,no_subtree_check,all_squash,anonuid=1000,anongid=100)

      # Export to Wireguard VPN clients (10.100.0.0/24)
      /mnt/storage 10.100.0.0/24(rw,sync,no_subtree_check,all_squash,anonuid=1000,anongid=100)
    '';
  };
}
