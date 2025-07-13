{ config
, lib
, pkgs
, ...
}: {
  # SSH daemon configuration
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };

    # SFTP subsystem configuration
    extraConfig = ''
      # SFTP-only configuration for storage access
      Match Group sftpusers
        ChrootDirectory /mnt/storage
        ForceCommand internal-sftp
        AllowTcpForwarding no
        X11Forwarding no
        PasswordAuthentication no
    '';
  };

  # SSH is already configured to open port 22 in firewall by default
}
