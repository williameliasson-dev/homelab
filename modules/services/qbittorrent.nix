{ config
, lib
, pkgs
, ...
}: {
  # Create qbittorrent user and group
  users.users.qbittorrent = {
    isSystemUser = true;
    group = "qbittorrent";
    home = "/var/lib/qbittorrent";
    createHome = true;
    extraGroups = [ "users" ];
  };
  
  users.groups.qbittorrent = {};

  # Install qbittorrent-nox package
  environment.systemPackages = with pkgs; [
    qbittorrent-nox
  ];

  # Create qbittorrent systemd service
  systemd.services.qbittorrent = {
    description = "qBittorrent daemon";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "forking";
      User = "qbittorrent";
      Group = "qbittorrent";
      ExecStart = "${pkgs.qbittorrent-nox}/bin/qbittorrent-nox -d --webui-port=8080";
      Restart = "on-failure";
    };
  };

  # Create downloads directory on storage
  systemd.services.qbittorrent-setup-dirs = {
    description = "Create qBittorrent download directories";
    wantedBy = [ "qbittorrent.service" ];
    before = [ "qbittorrent.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      mkdir -p /var/lib/qbittorrent
      mkdir -p /mnt/storage/downloads/incomplete
      mkdir -p /mnt/storage/downloads/complete
      chown -R qbittorrent:qbittorrent /var/lib/qbittorrent
      chown -R qbittorrent:qbittorrent /mnt/storage/downloads
      chmod -R 755 /var/lib/qbittorrent
      chmod -R 755 /mnt/storage/downloads
      # Give qbittorrent user access to jellyfin media directories
      usermod -a -G jellyfin qbittorrent
      # Set group write permissions on media directories if they exist
      if [ -d "/mnt/storage/media" ]; then
        chmod -R 775 /mnt/storage/media
      fi
    '';
  };

  # Open firewall for web UI
  networking.firewall.allowedTCPPorts = [ 8080 ];
}