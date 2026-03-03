{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs-lib.follows = "flake-parts/nixpkgs-lib";

    lib-module = {
      url = ./modules/lib.nix;
      flake = false;
    };

    overlays-module = {
      url = ./modules/overlays.nix;
      flake = false;
    };
  };

  outputs = { nixpkgs-lib, flake-parts, ... }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs-lib.lib.systems.flakeExposed;

      imports = [ flake-parts.flakeModules.flakeModules ];

      flake.flakeModules = with inputs; {
        default = self.flakeModules.lib;

        lib = import lib-module.outPath;

        overlays = import overlays-module.outPath;
      };
    };
}
