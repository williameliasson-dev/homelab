{ config
, lib
, pkgs
, ...
}: {
  # Define the encrypted secret
  age.secrets.wireguard-private = {
    file = ../../secrets/wireguard-private.age;
    owner = "systemd-network";
    group = "systemd-network";
    mode = "0400";
  };

  # Enable IP forwarding for routing
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  boot.kernel.sysctl."net.ipv6.conf.all.forwarding" = 1;

  # WireGuard configuration
  networking.wireguard.interfaces.wg0 = {
    # Server IP in the VPN subnet
    ips = [ "10.100.0.1/24" ];

    # WireGuard port
    listenPort = 51820;

    # Reference to encrypted private key
    privateKeyFile = config.age.secrets.wireguard-private.path;

    # Peers (clients that can connect)
    peers = [
      # Example peer - add your actual client public keys
      {
        # Client public key (safe to store in git)
        publicKey = "CLIENT_PUBLIC_KEY_HERE";

        # IP assigned to this client
        allowedIPs = [ "10.100.0.2/32" ];

        # Optional: Persistent keepalive for mobile clients
        persistentKeepalive = 25;
      }

      # Add more clients as needed
      # {
      #   publicKey = "ANOTHER_CLIENT_PUBLIC_KEY";
      #   allowedIPs = [ "10.100.0.3/32" ];
      #   persistentKeepalive = 25;
      # }
    ];

    # Post-up and post-down commands for NAT
    postSetup = ''
      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
      ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -j ACCEPT
      ${pkgs.iptables}/bin/iptables -A FORWARD -o wg0 -j ACCEPT
    '';

    postShutdown = ''
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
      ${pkgs.iptables}/bin/iptables -D FORWARD -i wg0 -j ACCEPT
      ${pkgs.iptables}/bin/iptables -D FORWARD -o wg0 -j ACCEPT
    '';
  };

  # Open firewall port for WireGuard
  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
    # Enable NAT for WireGuard clients
    trustedInterfaces = [ "wg0" ];
  };
}
