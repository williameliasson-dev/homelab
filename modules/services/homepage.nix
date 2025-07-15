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

  # Override the entire homepage service to run as root
  systemd.services.homepage-dashboard = lib.mkForce {
    description = "Homepage Dashboard";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "root";
      Group = "root";
      DynamicUser = false;
      PrivateUsers = false;
      ExecStart = "${pkgs.homepage-dashboard}/bin/homepage";
      WorkingDirectory = "/var/lib/homepage-dashboard";
      StateDirectory = "homepage-dashboard";
      Restart = "on-failure";
    };
    environment = {
      PORT = "80";
      HOMEPAGE_VAR_PORT = "80";
      HOMEPAGE_ALLOWED_HOSTS = "homelab.local,localhost,192.168.0.109";
    };
  };
}