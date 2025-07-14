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
  systemd.tmpfiles.rules = [
    "d /var/lib/qbittorrent 0755 qbittorrent qbittorrent -"
    "d /mnt/storage/downloads 0755 qbittorrent qbittorrent -"
    "d /mnt/storage/downloads/incomplete 0755 qbittorrent qbittorrent -"
    "d /mnt/storage/downloads/complete 0755 qbittorrent qbittorrent -"
  ];

  # Open firewall for web UI
  networking.firewall.allowedTCPPorts = [ 8080 ];
}