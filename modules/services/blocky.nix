{ config, lib, pkgs, ... }:

{
  services.blocky = {
    enable = true;
    settings = {
      # Upstream DNS servers
      upstream = {
        default = [
          "1.1.1.1"
          "1.0.0.1"
          "8.8.8.8"
          "8.8.4.4"
        ];
      };

      # Custom DNS mappings for local services
      customDNS = {
        customTTL = "1h";
        mapping = {
          "homelab.local" = "192.168.1.100";  # Adjust to your homelab IP
        };
      };

      # Ad blocking configuration
      blocking = {
        blackLists = {
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
        whiteLists = {
          ads = [
            "https://raw.githubusercontent.com/anudeepND/whitelist/master/domains/whitelist.txt"
          ];
        };
        clientGroupsBlock = {
          default = [ "ads" "youtube" ];
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

      # Web interface and DNS settings
      httpPort = 4000;
      port = 53;
      logLevel = "info";
    };
  };

  # Open firewall ports
  networking.firewall = {
    allowedTCPPorts = [ 53 4000 ];
    allowedUDPPorts = [ 53 ];
  };

  # Optional: Set this server as the system DNS
  # networking.nameservers = [ "127.0.0.1" ];
}