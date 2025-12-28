{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    {
      overlays.default = final: prev: {
        breezewiki = final.callPackage ./default.nix { };
      };

      packages.x86_64-linux = {
        default = pkgs.callPackage ./default.nix { };

        # nix run .#test-service.driverInteractive
        test-service = pkgs.callPackage ./test.nix {
          inherit self;
        };
      };

      checks.x86_64-linux = {
        test-service = pkgs.callPackage ./test.nix {
          inherit self;
        };
      };

      nixosModules.default = import ./module.nix;
    };
}
