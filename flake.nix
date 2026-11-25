{
  description = "Herdr desktop app and Herdr Core for x86-64 Linux";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { nixpkgs, ... }:
    {
      packages.x86_64-linux =
        let
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          herdr-core = pkgs.callPackage ./herdr-core.nix { };
          herdr-app = pkgs.callPackage ./herdr-app.nix { inherit herdr-core; };
        in
        {
          inherit herdr-app herdr-core;
          default = herdr-app;
        };
    };
}
