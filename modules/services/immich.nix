{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.services.immich-server;
in
{
  options.services.immich-server = {
    enable = lib.mkEnableOption "Immich photo and video backup service";

    host = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "Host to bind to";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 2283;
      description = "Port to listen on";
    };

    mediaLocation = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/immich";
      description = "Location to store uploaded photos and videos";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open firewall port for Immich";
    };
  };

  config = lib.mkIf cfg.enable {
    services.immich = {
      enable = true;
      host = cfg.host;
      port = cfg.port;
      mediaLocation = cfg.mediaLocation;
    };

    # Open firewall if requested
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.port ];

    # Add immich user to storage group for shared storage access
    users.users.immich.extraGroups = [ "storage" ];

    # Hardware acceleration for video processing
    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver # For Intel GPUs
      ];
    };

    users.users.immich.extraGroups = [
      "video" # For hardware acceleration
      "render" # For hardware acceleration
      "storage" # For shared storage access
    ];
  };
}
