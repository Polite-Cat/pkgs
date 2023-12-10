{
  outputs = { self }: {
    legacyPackages = forAllSystems (system: import ./. { inherit system; });
  };
}
