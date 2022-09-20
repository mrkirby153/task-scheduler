{
    pkgs ? import (
        builtins.fetchTarball {
            name = "nixpkgs-unstable-2022-09-17";
            url = "https://github.com/nixos/nixpkgs/archive/9c2a7cc09d66fb7ffbc9609abe4d6d1521834152.tar.gz";
            sha256 = "1rx2g6qg5gyavm7k7ssxqi12qxwwjshd8z0ca3sgba15ynda7l1q";
        }
    ) {}
}:
let
    elixirProtoc = import ./nix/protobuf.nix { inherit pkgs; };
in
    pkgs.mkShell {
        buildInputs = with pkgs; [
            elixir
            protobuf
            elixirProtoc
            buf
        ];
    }
