{ config
, lib
, pkgs
, ...
}: {
  systemd.services.storage-setup = {
    description = "Setup storage directories for all services";
    wantedBy = [ "multi-user.target" ];
    before = [ "jellyfin.service" "qbittorrent.service" ];
    after = [ "mnt-storage.mount" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      # Create all required directories
      mkdir -p /mnt/storage/media/movies
      mkdir -p /mnt/storage/media/shows
      mkdir -p /mnt/storage/downloads/incomplete
      mkdir -p /mnt/storage/downloads/complete
      
      # Set proper ownership and permissions
      # Media directories: owned by jellyfin, group jellyfin, group-writable
      chown -R jellyfin:jellyfin /mnt/storage/media
      chmod -R 775 /mnt/storage/media
      
      # Downloads directories: owned by qbittorrent, group qbittorrent
      chown -R qbittorrent:qbittorrent /mnt/storage/downloads
      chmod -R 755 /mnt/storage/downloads
      
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