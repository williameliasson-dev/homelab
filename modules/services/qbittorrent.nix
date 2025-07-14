{ config
, lib
, pkgs
, ...
}: {
  services.qbittorrent = {
    enable = true;
    openFirewall = true;
    
    # Web UI configuration
    port = 8080;
    
    # Download directories
    dataDir = "/var/lib/qbittorrent";
    
    # User and group
    user = "qbittorrent";
    group = "qbittorrent";
  };

  # Create downloads directory on storage
  systemd.tmpfiles.rules = [
    "d /mnt/storage/downloads 0755 qbittorrent qbittorrent -"
    "d /mnt/storage/downloads/incomplete 0755 qbittorrent qbittorrent -"
    "d /mnt/storage/downloads/complete 0755 qbittorrent qbittorrent -"
  ];

  # Add qbittorrent user to necessary groups
  users.users.qbittorrent.extraGroups = [
    "users"
  ];
}