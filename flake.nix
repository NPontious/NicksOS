{
  description = "NixOS configurations for multiple machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    jovian.url = "github:Jovian-Experiments/Jovian-NixOS";
    jovian.inputs.nixpkgs.follows = "nixpkgs";

    illogical-flake.url = "github:soymou/illogical-flake";
    illogical-flake.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, jovian, illogical-flake, home-manager, agenix, ... }: {
    nixosConfigurations = {
      glacio = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit illogical-flake agenix; };
        modules = [
          ./hosts/glacio/hardware-configuration.nix
          ./hosts/glacio/configuration.nix
          jovian.nixosModules.default
          home-manager.nixosModules.home-manager
          agenix.nixosModules.default
        ];
      };

      vesania = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit illogical-flake agenix; };
        modules = [
          ./hosts/vesania/hardware-configuration.nix
          ./hosts/vesania/configuration.nix
          home-manager.nixosModules.home-manager
          agenix.nixosModules.default
        ];
      };

      sylva = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit illogical-flake agenix; };
        modules = [
          ./hosts/sylva/hardware-configuration.nix
          ./hosts/sylva/configuration.nix
          home-manager.nixosModules.home-manager
          agenix.nixosModules.default
        ];
      };
    };
  };
}
