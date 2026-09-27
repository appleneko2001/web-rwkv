{
  description = "web-rwkv";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-safetensors_0-6-2.url = "github:NixOS/nixpkgs/6238ed3a0f8e3fcca4d3b8ba52afaae14c99cfa9";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      flake-utils,
      nixpkgs,
      nixpkgs-safetensors_0-6-2,
    }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        pkgs_safetensors_0-6-2 = import nixpkgs-safetensors_0-6-2 {
          inherit system;
        };
      in
      {
        packages.default = pkgs.rustPlatform.buildRustPackage {
          pname = "web-rwkv";
          version = "v0.10.20_20260927";
          src = ./.;

          meta = {
            description = "web-rwkv (origin: https://github.com/cryscan/web-rwkv/tree/v0.10.20)";
            homepage = "https://github.com/appleneko2001/web-rwkv";
            license = builtins.readFile ./LICENSE;
            maintainers = [ ];
          };

          cargoLock.lockFile = ./Cargo.lock;
          doCheck = false;
        };

        packages.python3_convert_safetensors =
          let
            python3 = pkgs.python3.withPackages (ps: [
              ps.numpy
              ps.torch
              pkgs_safetensors_0-6-2.python3Packages.safetensors
              #               ps.safetensors
            ]);
          in
          pkgs.writeShellApplication {
            name = "web-rwkv-convert_safetensors";

            runtimeInputs = [
              python3
            ];

            text = ''
              exec ${python3}/bin/python3 ${./.}/assets/scripts/convert_safetensors.py "$@"
            '';
          };
      }
    );
}
