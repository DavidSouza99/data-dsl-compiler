{
  description = "data-dsl-compiler - DSL para pipelines de dados";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          pkgs.haskell.compiler.ghc967
          pkgs.cabal-install
          pkgs.haskellPackages.alex
          pkgs.haskellPackages.happy
        ];
        shellHook = ''
          echo "Ambiente data-dsl-compiler pronto (GHC 9.6.7)"
        '';
      };
    };
}
