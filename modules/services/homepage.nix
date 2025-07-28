{ config
, lib
, pkgs
, ...
}: {
  services.homepage-dashboard = {
    enable = true;
    openFirewall = true;
    listenPort = 80;
    
    settings = {
      title = "Homelab Dashboard";
      theme = "dark";
      color = "slate";
    };
    
    services = [
      {
        "Media & Downloads" = [
          {
            "Jellyfin" = {
              icon = "jellyfin.png";
              href = "http://homelab.local:8096";
              description = "Media Server";
            };
          }
          {
            "qBittorrent" = {
              icon = "qbittorrent.png";
              href = "http://homelab.local:8080";
              description = "Torrent Client";
            };
          }
        ];
      }
      {
        "System" = [
          {
            "Blocky" = {
              icon = "blocky.png";
              href = "http://homelab.local:4000";
              description = "DNS Ad Blocker";
            };
          }
        ];
      }
    ];
    
    widgets = [
      {
        resources = {
          cpu = true;
          memory = true;
          disk = "/";
        };
      }
    ];
  };

  # Override only the user settings to run as root, preserve the rest
  systemd.services.homepage-dashboard.serviceConfig = {
    User = lib.mkForce "root";
    Group = lib.mkForce "root";
    DynamicUser = lib.mkForce false;
    PrivateUsers = lib.mkForce false;
  };
}