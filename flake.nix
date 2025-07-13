{
  description = "Homelab NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";
  };

  outputs = { self, nixpkgs, nixpkgs-stable, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      nixosConfigurations = {
        homelab = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./hosts/homelab/configuration.nix
          ];
          specialArgs = {
            inherit nixpkgs-stable;
          };
        };
      };

      devShells.${system}.default = pkgs.mkShell {
        buildInputs = with pkgs; [
          nixos-rebuild
          git
        ];
      };
    };
}