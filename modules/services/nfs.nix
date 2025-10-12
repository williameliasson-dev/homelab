{ config
, lib
, pkgs
, ...
}:
with lib; let
  cfg = config.services.nfs-server;
in
{
  options.services.nfs-server = {
    enable = mkEnableOption "NFS server for homelab storage";

    exports = mkOption {
      type = types.lines;
      default = "";
      description = "NFS exports configuration";
      example = ''
        /mnt/storage 192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash)
      '';
    };
  };

  config = mkIf cfg.enable {
    # Create NFS user for remote access
    users.users.nfsuser = {
      isSystemUser = true;
      group = "nfsuser";
      extraGroups = [ "storage" ];
    };

    users.groups.nfsuser = {};

    # Enable NFS server
    services.nfs.server = {
      enable = true;
      exports = cfg.exports;
    };

    # Open firewall ports for NFS
    networking.firewall = {
      allowedTCPPorts = [
        111   # rpcbind
        2049  # nfsd
        4000  # nfs-callback
        4001  # nlockmgr
        4002  # mountd
        20048 # mountd
      ];
      allowedUDPPorts = [
        111   # rpcbind
        2049  # nfsd
        4000  # nfs-callback
        4001  # nlockmgr
        4002  # mountd
        20048 # mountd
      ];
    };

    # Ensure proper NFS services are enabled
    systemd.services.nfs-server = {
      after = [ "mnt-storage.mount" ];
      requires = [ "mnt-storage.mount" ];
    };
  };
}
