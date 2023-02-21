{
  description = "Application packaged using poetry2nix";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.poetry2nix = {
    url = "github:nix-community/poetry2nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.src = {
    url = "github:trestripes-com/pycubelut";
    flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix, src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # see https://github.com/nix-community/poetry2nix/tree/master#api for more functions and examples.
        inherit (poetry2nix.legacyPackages.${system}) mkPoetryApplication;
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = rec {
          cubelut = mkPoetryApplication {
            projectDir = src;
            overrides = poetry2nix.legacyPackages.${system}.overrides.withDefaults (self: super: {
              inherit (pkgs.python3Packages) numpy scipy;
              colour-science = super.colour-science.overridePythonAttrs (old: {
                buildInputs = (old.buildInputs or []) ++ [ super.poetry ];
              });
            });
          };
          default = cubelut;
        };

        devShells.default = pkgs.mkShell {
          packages = [ poetry2nix.packages.${system}.poetry ];
        };
      });
}
