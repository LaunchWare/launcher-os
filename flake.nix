{
  description = "launcher-os: a Hyprland + DankMaterialShell workstation on NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Fast-moving desktop stack. Each keeps its own nixpkgs on purpose: following
    # the stable base is a documented cause of Hyprland build failures and cache misses.
    hyprland.url = "github:hyprwm/Hyprland";
    dms.url = "github:AvengeMedia/DankMaterialShell/stable";
    vicinae.url = "github:vicinaehq/vicinae";
    handy.url = "github:cjpais/Handy";
  };

  outputs =
    {
      self,
      nixpkgs,
      disko,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      launcherPkgs = pkgs.callPackage ./pkgs { inherit (disko.packages.${system}) disko; };

      mkHost =
        hostName:
        nixpkgs.lib.nixosSystem {
          modules = [
            self.nixosModules.default
            disko.nixosModules.disko
            ./hosts/${hostName}
          ];
        };
    in
    {
      nixosModules.default = import ./modules inputs;

      nixosConfigurations.madthinkpad = mkHost "madthinkpad";

      apps.${system}.install = {
        type = "app";
        program = "${launcherPkgs.install}/bin/launcher-os-install";
        meta.description = "Partition, format and install a launcher-os host from the NixOS ISO";
      };
    };
}
