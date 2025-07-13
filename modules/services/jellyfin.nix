{ config, lib, pkgs, ... }:

{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
    
    # Jellyfin runs on port 8096 by default
    # Data directory: /var/lib/jellyfin
    # Config directory: /var/lib/jellyfin/config
    # Cache directory: /var/cache/jellyfin
    # Log directory: /var/log/jellyfin
  };

  # Create systemd mount units for media directories
  systemd.tmpfiles.rules = [
    # Create media directories on your RAID array
    "d /mnt/storage/media 0755 jellyfin jellyfin -"
    "d /mnt/storage/media/movies 0755 jellyfin jellyfin -"
    "d /mnt/storage/media/shows 0755 jellyfin jellyfin -"
  ];

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
  # hardware.opengl = {
  #   enable = true;
  #   extraPackages = with pkgs; [
  #     intel-media-driver  # For Intel GPUs
  #     # nvidia-vaapi-driver  # For NVIDIA GPUs
  #   ];
  # };

  # Add jellyfin user to any additional groups if needed
  users.users.jellyfin.extraGroups = [ 
    # "video"  # For hardware acceleration
    # "render" # For hardware acceleration
  ];
}