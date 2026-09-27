{
  description = "web-rwkv";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    flake-utils,
    nixpkgs,
  }: flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
    let
      pkgs = import nixpkgs {
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
          maintainers = [  ];
        };

        cargoLock.lockFile = ./Cargo.lock;
        doCheck = false;
      };
    }
  );
}
