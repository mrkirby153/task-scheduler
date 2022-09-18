{ pkgs ? import <nixpkgs> { } }:
with pkgs;
let
    packages = beam.packagesWith beam.interpreters.erlang;

    pname = "protobuf";
    version = "0.11.0";

    src = builtins.fetchGit {
        url = "https://github.com/elixir-protobuf/protobuf";
        rev = "cdf3acc53f619866b4921b8216d2531da52ceba7";
        ref = "main";
    };

    mixFodDeps = packages.fetchMixDeps {
        pname = "${pname}-mix-deps";
        inherit src version;
        sha256 = "sha256-H7yiBHoxuiqWcNbWwPU5X0Nnv8f6nM8z/ZAfZAGPZjE=";
    };
in packages.mixRelease {
    inherit src pname version mixFodDeps;

    postBuild = ''
        mix escript.build
        mkdir -p $out/bin
        cp protoc-gen-elixir $out/bin
    '';

    postInstall = ''
        rm -rf $out/bin/protobuf
    '';
}