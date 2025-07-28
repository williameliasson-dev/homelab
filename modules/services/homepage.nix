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

  # Override to run as root with proper capabilities for port 80
  systemd.services.homepage-dashboard.serviceConfig = {
    User = lib.mkForce "root";
    Group = lib.mkForce "root";
    DynamicUser = lib.mkForce false;
    PrivateUsers = lib.mkForce false;
    AmbientCapabilities = lib.mkForce "CAP_NET_BIND_SERVICE";
    CapabilityBoundingSet = lib.mkForce "CAP_NET_BIND_SERVICE";
  };
  
  # Ensure environment variables are properly set
  systemd.services.homepage-dashboard.environment = {
    PORT = lib.mkForce "80";
    HOMEPAGE_VAR_PORT = lib.mkForce "80";
  };
}