{ config
, pkgs
, lib
, nixpkgs-stable
, ...
}: {
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
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHLhqTjuSrzwdJoVmJXQlcAXV+I0YJ9Fd/7Di+59sGb0 williameliasson5@gmail.com"
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
}
