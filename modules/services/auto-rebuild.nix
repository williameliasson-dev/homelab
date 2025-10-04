{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.auto-rebuild;
in
{
  options.services.auto-rebuild = {
    enable = mkEnableOption "automatic NixOS configuration rebuild from git";

    interval = mkOption {
      type = types.str;
      default = "*/15 * * * *";
      description = "Cron interval for checking updates (default: every 15 minutes)";
    };

    repoPath = mkOption {
      type = types.str;
      default = "/etc/nixos";
      description = "Path to the git repository";
    };

    flakePath = mkOption {
      type = types.str;
      default = "/etc/nixos";
      description = "Path to the flake for nixos-rebuild";
    };

    hostName = mkOption {
      type = types.str;
      default = config.networking.hostName;
      description = "NixOS configuration name from flake";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.auto-rebuild = {
      description = "Auto-rebuild NixOS configuration from git";
      path = with pkgs; [ git nixos-rebuild ];

      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };

      script = ''
        set -e
        cd ${cfg.repoPath}

        # Fetch latest changes
        git fetch origin

        # Check if there are updates
        LOCAL=$(git rev-parse HEAD)
        REMOTE=$(git rev-parse origin/master)

        if [ "$LOCAL" != "$REMOTE" ]; then
          echo "Updates found, pulling and rebuilding..."
          git pull
          nixos-rebuild switch --flake ${cfg.flakePath}#${cfg.hostName}
          echo "Rebuild completed successfully"
        else
          echo "No updates found"
        fi
      '';
    };

    systemd.timers.auto-rebuild = {
      description = "Timer for auto-rebuild service";
      wantedBy = [ "timers.target" ];

      timerConfig = {
        OnCalendar = cfg.interval;
        Persistent = true;
      };
    };
  };
}
