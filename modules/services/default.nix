{ config
, lib
, pkgs
, ...
}: {
  imports = [
    # Service modules will be imported here
    ./jellyfin.nix
    # ./wireguard.nix
    # ./storage.nix
    ./blocky.nix
  ];
}
