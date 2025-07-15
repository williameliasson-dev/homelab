{ config
, lib
, pkgs
, ...
}: {
  # Create SFTP user group
  users.groups.sftpusers = { };

  # Create SFTP user for storage access
  users.users.sftp = {
    isNormalUser = true;
    group = "sftpusers";
    extraGroups = [ "sftpusers" ];
    home = "/mnt/storage";
    createHome = false;
    shell = pkgs.bash;

    openssh.authorizedKeys.keys = [
      # Add your SSH public keys here for SFTP access
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHLhqTjuSrzwdJoVmJXQlcAXV+I0YJ9Fd/7Di+59sGb0 williameliasson5@gmail.com"
    ];
  };

  # Give sftp user access to the entire storage mount
  systemd.tmpfiles.rules = [
    # Ensure sftp user can access the storage
    "Z /mnt/storage 0755 sftp sftpusers -"
  ];
}
