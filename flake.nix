{
  description = "A task scheduler";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      buildInputs = with pkgs; [
        elixir
      ];
    in {
      packages.default = pkgs.beamPackages.mixRelease {
        version = "v0.1.0";
        name = "task-scheduler";
        pname = "task-scheduler";
        src = ./.;
        mixNixDeps = with pkgs; import ./mix_deps.nix { inherit lib beamPackages; };
      };
      devShells = {
        default = pkgs.mkShell {
          buildInputs = buildInputs ++ [
            pkgs.mix2nix
          ];
        };
      };
    });
}
