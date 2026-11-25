{
  description = "Herdr desktop app and Herdr Core for x86-64 Linux";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      herdr-core = pkgs.callPackage ./herdr-core.nix { };
      herdr-app = pkgs.callPackage ./herdr-app.nix { inherit herdr-core; };
    in
    {
      packages.${system} = {
        inherit herdr-app herdr-core;
        default = herdr-app;
      };
      checks.${system}.smoke = pkgs.callPackage ./tests/smoke.nix { inherit herdr-app herdr-core; };
    };
}
