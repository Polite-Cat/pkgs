{
  outputs = { self, nixpkgs, ... }:
  let
    forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
  in
  {
    legacyPackages = forAllSystems (system: import ./. { inherit system; });
  };
}
