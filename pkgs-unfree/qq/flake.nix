{
  description = "A very basic flake";

  inputs = {
    # 
  };

  outputs = { self, nixpkgs }:
    let pkgs = import nixpkgs { system = "x86_64-linux"; }; in {
      # system = builtins.currentSystem;
      # 使用nix build .#fuck
      packages.x86_64-linux.default = pkgs.callPackage ./default.nix { };
    };
}
