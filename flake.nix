{
  description = "Herdr desktop app and Herdr Core for Linux";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { nixpkgs, ... }:
    {
      packages = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          herdr-core = pkgs.callPackage ./herdr-core.nix { };
          herdr-app = pkgs.callPackage ./herdr-app.nix { inherit herdr-core; };
        in
        {
          inherit herdr-app herdr-core;
          default = herdr-app;
        }
      );
    };
}
