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
    extraGroups = [ "storage" ]; # Add to shared storage group
    home = "/mnt/storage";
    createHome = false;
    shell = pkgs.bash;

    openssh.authorizedKeys.keys = [
      # Add your SSH public keys here for SFTP access
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGLHJ09aA0rj9RkI7XjzK51hGNV2/nnANikt7f5aSLZP williameliasson5@gmail.com"
    ];
  };
}
