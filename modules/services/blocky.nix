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

      # Upstream DNS servers (with IPv6 support for Apple devices)
      upstreams = {
        groups = {
          default = [
            "1.1.1.1"
            "1.0.0.1"
            "2606:4700:4700::1111"
            "2606:4700:4700::1001"
            "8.8.8.8"
            "8.8.4.4"
            "2001:4860:4860::8888"
            "2001:4860:4860::8844"
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

      # Caching configuration (helps with Apple device compatibility)
      caching = {
        minTime = "5m";
        maxTime = "30m";
        cacheTimeNegative = "30m";
      };

      # Enable EDNS for better compatibility
      ede = {
        enable = true;
      };

      # Prometheus metrics
      prometheus = {
        enable = true;
        path = "/metrics";
      };
    };
  };

  # Open firewall ports (IPv4 and IPv6)
  networking.firewall = {
    allowedTCPPorts = [
      53
      4000
    ];
    allowedUDPPorts = [ 53 ];
    # Allow IPv6 DNS traffic
    allowedTCPPortRanges = [];
    allowedUDPPortRanges = [];
  };

  # Optional: Set this server as the system DNS
  # networking.nameservers = [ "127.0.0.1" ];
}
