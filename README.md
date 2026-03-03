# flake-modules

Personal flake modules for recurring needs.

flake modules:
- `lib` - Adds support to flake-parts for top-level `lib` flake output
- `overlays` - Makes consuming overlays easy by allowing for overlays
    to be provided through a simple top-level field `overlays`.

## Quickstart

using `flakeModules.lib`:

```nix
{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs-lib.follows = "flake-parts/nixpkgs-lib";

    flake-modules.url = "github:MaxTheMooshroom/flake-modules";
  };

  outputs = { nixpkgs-lib, flake-parts, flake-modules, ... }@inputs:
    flake-parts.lib.mkFlake { inherit system; } {
      # covers the main systems.
      systems = nixpkgs-lib.lib.systems.flakeExposed;

      imports = [ flake-modules.flakeModules.lib ];

      # without the flake module, flake-parts will error
      # over this when the flake is evaluated.
      flake.lib = {
        my-function = _: null;
      };
    };
}
```

using `flakeModules.overlays`:

```nix
{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs-lib.follows = "flake-parts/nixpkgs-lib";

    flake-modules.url = "github:MaxTheMooshroom/flake-modules";

    nixpkgs.url = "github:NixOS/nixpkgs/25.11";

    my-overlay = {
      url = ./overlay.nix;
      flake = false;
    };
  };

  outputs = { nixpkgs-lib, flake-parts, flake-modules, ... }@inputs:
    flake-parts.lib.mkFlake { inherit system; } {
      # covers the main systems.
      systems = nixpkgs-lib.lib.systems.flakeExposed;

      imports = [ flake-modules.flakeModules.overlays ];

      overlays = [ inputs.my-overlay ];

      # Without the flake module, this is how you'd go about applying
      # an overlay to nixpkgs. It's not a lot, but this is about
      # reducing how much the developer (probably myself) and readers
      # need to think about what's going on, and keeping common
      # activities concise.
      perSystem = { system, pkgs, ... }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;

          overlays = [ inputs.my-overlay ];
        };
      };
    };
}
```

