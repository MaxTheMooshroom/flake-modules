{ inputs, config, lib, ... }:
let
  inherit (lib) mkOption types;

  overlay = types.unspecified;
in
{
  options.overlays = mkOption {
    type = types.attrsOf (types.listOf overlay);
    default = {};

    description = ''
      An attribute set of overlays that can be applied as needed.

      By default, `overlays.nixpkgs = [...];` will be applied to the
      `nixpkgs` flake input, if present. This is done as a special module
      argument for `pkgs` (`_module.args.pkgs = ...`).

      The attribute set produced by each overlay is expected to have
      entries that are either packages or package sets.

      Package sets are produced with
      ```nix
        pkgs.lib.makeScope pkgs.newScope (self: {
          package = pkgs.callPackage ./package.nix {};

          # OR
          package = self.callPackage ./package.nix {};

          # OR nested package sets.
        })
      ```
    '';
  };

  config = lib.mkIf (inputs ? nixpkgs) {
    perSystem = { system, ... }: {
      _module.args.pkgs = import inputs.nixpkgs {
        inherit system;
        overlays = config.overlays.nixpkgs or [];
      };
    };
  };
}
