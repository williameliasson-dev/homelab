{ config
, lib
, pkgs
, ...
}: {
  # Import age secrets
  age.secrets.couchdb-admin = {
    file = ../../secrets/couchdb-admin.age;
    owner = "couchdb";
    group = "couchdb";
    mode = "0400";
  };

  # Ensure couchdb starts after storage setup
  systemd.services.couchdb = {
    after = [ "storage-setup.service" ];
    wants = [ "storage-setup.service" ];
    serviceConfig = {
      ReadWritePaths = [ "/mnt/storage/couchdb" ];
    };
  };

  services.couchdb = {
    enable = true;

    # Bind to all interfaces so it's accessible on your network
    bindAddress = "0.0.0.0";
    port = 5984;

    # Store data on RAID array
    databaseDir = "/mnt/storage/couchdb/data";
    viewIndexDir = "/mnt/storage/couchdb/data";
    configFile = "/mnt/storage/couchdb/etc/local.ini";

    # Admin username (password comes from secret file)
    adminUser = "admin";

    # Use extraConfigFiles for secure password handling
    # The secret file should contain an INI section like:
    # [admins]
    # admin = -pbkdf2-...hashed password...
    extraConfigFiles = [ config.age.secrets.couchdb-admin.path ];

    # Extra configuration for Obsidian LiveSync
    extraConfig = {
      chttpd = {
        bind_address = "0.0.0.0";
        port = 5984;
        max_http_request_size = 4294967296;
      };

      couchdb = {
        max_document_size = 50000000;
      };

      httpd = {
        enable_cors = true;
      };

      cors = {
        origins = "app://obsidian.md, capacitor://localhost, http://localhost";
        credentials = true;
        headers = "accept, authorization, content-type, origin, referer";
        methods = "GET, PUT, POST, HEAD, DELETE";
      };
    };
  };

  # Open firewall for CouchDB
  networking.firewall.allowedTCPPorts = [ 5984 ];

  # Ensure couchdb user has access to storage group
  users.users.couchdb.extraGroups = [
    "storage" # For shared RAID storage access
  ];
}
