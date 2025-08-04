{ config
, lib
, pkgs
, ...
}: {
  # Create shared storage group
  users.groups.storage = { };

  systemd.services.storage-setup = {
    description = "Setup storage directories for all services";
    wantedBy = [ "multi-user.target" ];
    before = [ "jellyfin.service" "qbittorrent.service" "vaultwarden.service" ];
    after = [ "mnt-storage.mount" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      # Set ownership and permissions for the storage mount point
      chown root:storage /mnt/storage
      chmod 775 /mnt/storage
      
      # Create all required directories
      mkdir -p /mnt/storage/media/movies
      mkdir -p /mnt/storage/media/shows
      mkdir -p /mnt/storage/downloads/incomplete
      mkdir -p /mnt/storage/downloads/complete
      
      # Set proper ownership and permissions with shared storage group
      # Media directories: owned by jellyfin, group storage, group-writable
      chown -R jellyfin:storage /mnt/storage/media
      chmod -R 775 /mnt/storage/media
      
      # Downloads directories: owned by qbittorrent, group storage, group-writable
      chown -R qbittorrent:storage /mnt/storage/downloads
      chmod -R 775 /mnt/storage/downloads
      
      # Vaultwarden directory: owned by vaultwarden, group storage, group-writable
      mkdir -p /mnt/storage/vaultwarden
      chown -R vaultwarden:storage /mnt/storage/vaultwarden
      chmod -R 775 /mnt/storage/vaultwarden
      
      # Ensure service user home directories exist
      mkdir -p /var/lib/jellyfin
      mkdir -p /var/lib/qbittorrent
      chown jellyfin:jellyfin /var/lib/jellyfin
      chown qbittorrent:qbittorrent /var/lib/qbittorrent
      chmod 755 /var/lib/jellyfin
      chmod 755 /var/lib/qbittorrent
    '';
  };
}