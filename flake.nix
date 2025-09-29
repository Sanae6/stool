{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      with pkgs;
      {
        formatter = nixfmt-tree;
        inherit inputs;
        packages.default = pkgs.callPackage ./package.nix { };
        devShells.default = mkShellNoCC {
          buildInputs = [
            gnumake
            llvmPackages.clang-unwrapped
            llvmPackages.bintools-unwrapped
            iverilog
            (python3.withPackages (p: [

                (p.callPackage ./cocotb.nix {})
              p.pytest
            ]))
          ];
        };
      }
    );
}
