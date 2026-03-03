{ lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options.flake.lib = mkOption {
    type = types.attrsOf (
      types.coercedTo
        types.path
        builtins.import
        (types.functionTo types.anything)
    );

    description = ''
      Adds support to flake-parts for a top-level `lib` flake output.

      Any attributes of lib that are path objects will be assumed to
      point to nix files and imported as a nix expression.
    '';
  };
}
