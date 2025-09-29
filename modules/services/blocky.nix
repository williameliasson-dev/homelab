{ config
, lib
, pkgs
, ...
}: {
  services.blocky = {
    enable = true;
    settings = {
      # Log configuration
      log = {
        level = "info";
      };

      # Port configuration
      ports = {
        dns = 53;
        http = 4000;
      };

      # Upstream DNS servers
      upstreams = {
        groups = {
          default = [
            "1.1.1.1"
            "1.0.0.1"
            "8.8.8.8"
            "8.8.4.4"
          ];
        };
      };

      # Custom DNS mappings for local services
      customDNS = {
        customTTL = "1h";
        mapping = {
          "homelab.local" = "192.168.0.109";
        };
      };

      # Ad blocking configuration
      blocking = {
        denylists = {
          ads = [
            "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"
            "https://someonewhocares.org/hosts/zero/hosts"
            "https://raw.githubusercontent.com/AdguardTeam/AdguardFilters/master/BaseFilter/sections/adservers.txt"
            "https://pgl.yoyo.org/adservers/serverlist.php?hostformat=hosts&showintro=0&mimetype=plaintext"
          ];
          youtube = [
            "https://raw.githubusercontent.com/kboghdady/youTube_ads_4_pi-hole/master/black.list"
          ];
        };
        allowlists = {
          ads = [
            "https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt"
          ];
        };
        clientGroupsBlock = {
          default = [
            "ads"
            "youtube"
          ];
        };
      };

      # Enable query logging
      queryLog = {
        type = "console";
        logRetentionDays = 7;
      };

      # Prometheus metrics
      prometheus = {
        enable = true;
        path = "/metrics";
      };
    };
  };

  # Open firewall ports
  networking.firewall = {
    allowedTCPPorts = [
      53
      4000
    ];
    allowedUDPPorts = [ 53 ];
  };

  # Optional: Set this server as the system DNS
  # networking.nameservers = [ "127.0.0.1" ];
}
