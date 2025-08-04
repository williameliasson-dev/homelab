{ config
, lib
, pkgs
, ...
}: {
  # Import age secrets
  age.secrets.vaultwarden-admin-token = {
    file = ../../secrets/vaultwarden-admin-token.age;
    owner = "vaultwarden";
    group = "vaultwarden";
    mode = "0400";
  };
  # Ensure vaultwarden starts after storage setup and has proper environment
  systemd.services.vaultwarden = {
    after = [ "storage-setup.service" ];
    wants = [ "storage-setup.service" ];
    environment = {
      DATA_FOLDER = "/mnt/storage/vaultwarden";
    };
  };

  services.vaultwarden = {
    enable = true;

    # Environment file containing secrets
    environmentFile = config.age.secrets.vaultwarden-admin-token.path;

    config = {
      # Basic configuration
      ROCKET_ADDRESS = "0.0.0.0";
      ROCKET_PORT = 8222;

      # Data directory on RAID storage for redundancy
      DATA_FOLDER = "/mnt/storage/vaultwarden";

      # Database configuration (SQLite on RAID storage)
      DATABASE_URL = "/mnt/storage/vaultwarden/db.sqlite3";

      # Web vault configuration
      WEB_VAULT_ENABLED = true;

      # Security settings
      WEBSOCKET_ENABLED = true;
      WEBSOCKET_ADDRESS = "0.0.0.0";
      WEBSOCKET_PORT = 3012;

      # Domain configuration (update this to your domain)
      # DOMAIN = "https://vault.yourdomain.com";

      # Admin panel - token loaded from environmentFile
      # ADMIN_TOKEN will be loaded from the environment file

      # Email configuration (optional - configure via secrets)
      # SMTP_HOST = "smtp.gmail.com";
      # SMTP_FROM = "your-email@gmail.com";
      # SMTP_PORT = 587;
      # SMTP_SECURITY = "starttls";
      # SMTP_USERNAME = "your-email@gmail.com";
      # SMTP_PASSWORD = "your-app-password";

      # Disable registration by default (set to true if you want open registration)
      SIGNUPS_ALLOWED = false;

      # Allow existing users to invite new users
      INVITATIONS_ALLOWED = false;

      # Show password hints
      SHOW_PASSWORD_HINT = false;

      # Other security settings
      PASSWORD_ITERATIONS = 600000;
      EXTENDED_LOGGING = true;
      LOG_LEVEL = "info";
    };
  };

  # Open firewall ports
  networking.firewall.allowedTCPPorts = [
    8222
    3012
  ];

  # Backup configuration (optional)
  # systemd.services.vaultwarden-backup = {
  #   description = "Backup Vaultwarden data";
  #   serviceConfig = {
  #     Type = "oneshot";
  #     User = "vaultwarden";
  #     Group = "vaultwarden";
  #   };
  #   script = ''
  #     mkdir -p /mnt/storage/backups/vaultwarden
  #     cp -r /var/lib/vaultwarden/* /mnt/storage/backups/vaultwarden/
  #   '';
  # };

  # systemd.timers.vaultwarden-backup = {
  #   description = "Run Vaultwarden backup daily";
  #   wantedBy = [ "timers.target" ];
  #   timerConfig = {
  #     OnCalendar = "daily";
  #     Persistent = true;
  #   };
  # };

  # Ensure vaultwarden user has access to storage group
  users.users.vaultwarden.extraGroups = [
    "storage" # For shared RAID storage access
  ];
}
