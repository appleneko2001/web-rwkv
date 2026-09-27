{
  description = "web-rwkv";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      flake-utils,
      nixpkgs,
    }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        safetensors-0_6_2 = pkgs.python3Packages.safetensors.overrideAttrs (old: rec {
          version = "0.6.2";
          src = pkgs.fetchFromGitHub {
            owner = "huggingface";
            repo = "safetensors";
            tag = "v${version}";
            hash = "sha256-IyKk29jMAbYW+16mrpqQWjnsmNFEvUwkB048AAx/Cvw=";
          };
          cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
            inherit src;
            sourceRoot = "${src.name}/bindings/python";
            hash = "sha256-+92fCILZwk/TknGXgR9lRN55WnmkgUJfCszFthstzXs=";
          };
          postPatch = "";
        });
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
              ps.packaging
              safetensors-0_6_2
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
