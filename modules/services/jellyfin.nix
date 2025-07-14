{ config
, lib
, pkgs
, ...
}: {
  services.jellyfin = {
    enable = true;
    openFirewall = true;

    # Jellyfin runs on port 8096 by default
    # Data directory: /var/lib/jellyfin
    # Config directory: /var/lib/jellyfin/config
    # Cache directory: /var/cache/jellyfin
    # Log directory: /var/log/jellyfin
  };

  # Create media directories with proper systemd service
  systemd.services.jellyfin-setup-dirs = {
    description = "Create Jellyfin media directories";
    wantedBy = [ "jellyfin.service" ];
    before = [ "jellyfin.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      # Only create directories if they don't exist
      if [ ! -d "/mnt/storage/media" ]; then
        mkdir -p /mnt/storage/media/movies
        mkdir -p /mnt/storage/media/shows
        chown -R jellyfin:jellyfin /mnt/storage/media
        chmod -R 755 /mnt/storage/media
      fi
    '';
  };

  # Optional: Create symbolic links in jellyfin's data directory for easier management
  # systemd.services.jellyfin-media-links = {
  #   description = "Create Jellyfin media directory symlinks";
  #   wantedBy = [ "jellyfin.service" ];
  #   before = [ "jellyfin.service" ];
  #   serviceConfig = {
  #     Type = "oneshot";
  #     RemainAfterExit = true;
  #     User = "jellyfin";
  #     Group = "jellyfin";
  #   };
  #   script = ''
  #     mkdir -p /var/lib/jellyfin/media
  #     ln -sfn /mnt/storage/media/movies /var/lib/jellyfin/media/movies
  #     ln -sfn /mnt/storage/media/shows /var/lib/jellyfin/media/shows
  #   '';
  # };

  # Hardware acceleration (optional - uncomment if you have Intel or NVIDIA GPU)
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # For Intel GPUs
    ];
  };

  users.users.jellyfin.extraGroups = [
    "video" # For hardware acceleration
    "render" # For hardware acceleration
  ];
}
