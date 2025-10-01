{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    gowin-eda = {
      url = "github:Sanae6/gowin-eda-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      gowin-eda,
      fenix,
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ fenix.overlays.default ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
      in
      with pkgs;
      {
        formatter = nixfmt-tree;
        inherit inputs;
        packages.default = pkgs.callPackage ./package.nix { };
        devShells.default = mkShellNoCC {
          buildInputs = [
            llvmPackages.clang-unwrapped
            llvmPackages.bintools-unwrapped
            (pkgs.fenix.combine [
              pkgs.fenix.stable.defaultToolchain
              pkgs.fenix.stable.rust-src
            ])
            gnumake
            iverilog
            (python3.withPackages (p: [
              (p.callPackage ./cocotb.nix { })
              p.pytest
            ]))
          ];
          LD_LIBRARY_PATH = lib.makeLibraryPath (gowin-eda.gowinPackages pkgs);
        };
      }
    );
}
