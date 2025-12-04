{ lib, ... }:
{
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
              href = "http://192.168.0.105:8096";
              description = "Media Server";
            };
          }
          {
            "qBittorrent" = {
              icon = "qbittorrent.png";
              href = "http://192.168.0.105:8080";
              description = "Torrent Client";
            };
          }
          {
            "Immich" = {
              icon = "immich.png";
              href = "http://192.168.0.105:2283";
              description = "Image & Video Backup";
            };
          }
        ];
      }
      {
        "System" = [
          {
            "Blocky" = {
              icon = "blocky.png";
              href = "http://192.168.0.105:4000";
              description = "DNS Ad Blocker";
            };
          }
          {
            "Vaultwarden Admin" = {
              icon = "vaultwarden.png";
              href = "http://192.168.0.105:8222/admin";
              description = "Password Manager Admin";
            };
          }
          {
            "CouchDB (Fauxton)" = {
              icon = "couchdb.png";
              href = "http://192.168.0.105:5984/_utils";
              description = "Database for Obsidian Sync";
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
      {
        resources = {
          disk = "/mnt/storage";
          label = "Storage (RAID)";
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
    HOMEPAGE_ALLOWED_HOSTS = lib.mkForce "192.168.0.105,localhost,127.0.0.1";
  };
}
