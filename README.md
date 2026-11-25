# Herdr desktop app for Nix

This flake packages the official Herdr desktop and Core releases for x86-64 Linux. The desktop package includes the launcher and icon and supplies Core on the app's `PATH`. Herdr needs a graphical session and a working Vulkan driver. [Herdr desktop](https://github.com/herdrdev/herdr-app) · [Herdr Core](https://github.com/herdrdev/herdr-core)

Run Herdr from this checkout.

```sh
nix run .
```

Use `nix profile add .` to install the desktop package. Use `nix run .#herdr-core -- --help` to run `hc` directly, or `nix profile add .#herdr-core` to add `hc` and `herdr-core` to your shell.

For NixOS or Home Manager, add this flake as an input named `herdr-app` and include `inputs.herdr-app.packages.${pkgs.stdenv.hostPlatform.system}.default` in `environment.systemPackages` or `home.packages`.

Renovate opens pull requests that update the Herdr releases and their matching x86-64 archive checksums together. It also maintains `flake.lock` and the GitHub Actions pins. To update a release by hand, change its version and checksum in `herdr-app.nix` or `herdr-core.nix`, then run `nix build .#herdr-app .#herdr-core`. [Desktop release manifest](https://releases.herdr.dev/app/latest.json) · [Core release manifest](https://releases.herdr.dev/core/latest.json)

## Binary cache

GitHub Actions builds the x86-64 Linux package. Builds on `main` publish the app and its runtime dependencies to `haug1.cachix.org` when the repository has a `CACHIX_AUTH_TOKEN` secret with write access to that cache. Run **Build and cache Herdr** from the Actions tab to publish after adding the secret.
