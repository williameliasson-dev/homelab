{ config
, lib
, pkgs
, ...
}:
with lib; let
  cfg = config.services.samba-server;
in
{
  options.services.samba-server = {
    enable = mkEnableOption "Samba server for homelab storage";
  };

  config = mkIf cfg.enable {
    # Enable Samba
    services.samba = {
      enable = true;
      openFirewall = true;

      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = "Homelab Storage";
          "netbios name" = "homelab";
          "security" = "user";
          "hosts allow" = "192.168.0. 10.100.0. localhost";
          "hosts deny" = "0.0.0.0/0";
          "guest account" = "nobody";
          "map to guest" = "bad user";
        };

        # Main storage share
        "storage" = {
          "path" = "/mnt/storage";
          "browseable" = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0664";
          "directory mask" = "0775";
          "force group" = "storage";
          "valid users" = "homelab";
          "write list" = "homelab";
        };
      };
    };

    # Ensure Samba starts after storage is mounted
    systemd.services.samba-smbd = {
      after = [ "mnt-storage.mount" ];
      requires = [ "mnt-storage.mount" ];
    };
  };
}
