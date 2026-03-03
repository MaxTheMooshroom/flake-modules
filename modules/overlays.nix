{ config, lib, ... }:
let
  inherit (lib) mkOption types;

  packageSetEntry = types.either types.package packageSet;
  packageSet = types.attrsOf packageSetEntry;

  importable =
    types.either
      types.path
      ( types.addCheck
          (builtins.hasAttr "outPath")
          (types.attrsOf types.unspecified)
      );

  importableAs = types.coercedTo importable (
    overlay:
      assert (builtins.isAttrs overlay) -> (overlay ? outPath);

      builtins.import (
        if    builtins.isAttrs overlay
        then  overlay.outPath
        else  overlay
      )
  );

  overlay = types.functionTo (types.functionTo (types.attrsOf packageSetEntry));
in
{
  options.overlays = mkOption {
    type = types.listOf (importableAs overlay);
    default = [];

    description = ''
      A list of overlays to apply to the `nixpkgs` flake input, if present.

      The attribute set produced by the overlay is expected to have entries
      that are either packages or package sets.

      Package sets are produced with
      ```nix
        pkgs.lib.makeScope pkgs.newScope (self: {
          package = pkgs.callPackage ./package.nix {};

          # OR
          package = self.callPackage ./package.nix {};

          # OR nested package sets.
        })
      ```

      A path that points to a nix file containing the overlay is equally valid.

      An attribute set with `outPath` that points to a nix file
      containing the overlay is equally valid.
    '';
  };

  config.perSystem = { system, inputs', ... }: {
    _module.args.pkgs = import inputs'.nixpkgs {
      inherit system;
      inherit (config) overlays;
    };
  };
}
