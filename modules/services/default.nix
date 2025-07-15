{ config
, lib
, pkgs
, ...
}: {
  imports = [
    # Service modules will be imported here
    ./jellyfin.nix
    ./wireguard.nix
    ./ssh.nix
    ./sftp.nix
    ./blocky.nix
    ./qbittorrent.nix
    ./storage-setup.nix
  ];
}
