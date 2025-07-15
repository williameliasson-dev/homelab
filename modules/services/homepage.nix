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
      
      layout = {
        "Media & Downloads" = {
          style = "row";
          columns = 2;
        };
        "System" = {
          style = "row";
          columns = 3;
        };
      };
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
          {
            "System Monitor" = {
              icon = "glances.png";
              href = "#";
              description = "System Stats";
              widget = {
                type = "resources";
                cpu = true;
                memory = true;
                disk = "/";
              };
            };
          }
          {
            "RAID Storage" = {
              icon = "disk.png";
              href = "#";
              description = "RAID 6 Array";
              widget = {
                type = "disk";
                path = "/mnt/storage";
              };
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
        search = {
          provider = "duckduckgo";
          target = "_blank";
        };
      }
    ];
  };

  # Configure homepage systemd service to run as root
  systemd.services.homepage-dashboard = {
    serviceConfig = {
      User = lib.mkForce "root";
      Group = lib.mkForce "root";
    };
  };
}