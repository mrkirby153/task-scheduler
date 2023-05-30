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
    in rec {
      packages.default = pkgs.beamPackages.mixRelease {
        version = "v0.1.0";
        name = "task-scheduler";
        pname = "task-scheduler";
        src = ./.;
        mixNixDeps = with pkgs; import ./mix_deps.nix { inherit lib beamPackages; };
      };
      packages.docker = pkgs.dockerTools.buildImage {
        name = "task-scheduler";
        tag = "latest";
        copyToRoot = pkgs.buildEnv {
          name = "image-root";
          paths = [ packages.default pkgs.busybox ];
          pathsToLink = [ "/bin" ];
        };
        runAsRoot = ''
        #!${pkgs.runtimeShell}
        mkdir -p /data
        '';
        config = {
          Cmd = [ "${packages.default}/bin/task_scheduler" "start" ];
          WorkingDir = "/data";
          Env = [ "LOCALE=en_US.UTF-8" ];
        };
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
