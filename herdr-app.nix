{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  fontconfig,
  git,
  herdr-core,
  libglvnd,
  libxcb,
  libxkbcommon,
  vulkan-loader,
  wayland,
  xdg-utils,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "herdr-app";
  version = "0.1.18";

  src = fetchurl {
    url = "https://releases.herdr.dev/app/${finalAttrs.version}/herdr-app-linux-${stdenv.hostPlatform.parsed.cpu.name}.tar.gz";
    hash =
      {
        x86_64-linux = "sha256-ihHt153UCzSfcobPUZELYuIRNtr48DAFqf0sTcWDD4M=";
        aarch64-linux = "sha256-O/UVBcsefWHmPM3CZV6IGfS0Urq+rZki/ku2/mnpE1A=";
      }
      .${stdenv.hostPlatform.system};
  };

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
  ];

  buildInputs = [
    fontconfig
    libxcb
    libxkbcommon
    stdenv.cc.cc.lib
  ];

  # These libraries are loaded at runtime by the Linux graphics backends.
  runtimeDependencies = [
    libglvnd
    libxkbcommon
    vulkan-loader
    wayland
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "herdr-app";
      desktopName = "Herdr";
      comment = "Terminals and coding agents that keep running";
      exec = "herdr-app";
      icon = "herdr-app";
      startupWMClass = "herdr-app";
      categories = [ "Development" ];
    })
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 herdr-app "$out/libexec/herdr-app"
    # Keep the icon away from the executable so upstream's updater skips the app.
    install -Dm644 herdr-app.svg "$out/share/icons/hicolor/scalable/apps/herdr-app.svg"
    install -Dm644 -t "$out/share/licenses/herdr-app" LICENSE THIRD-PARTY-NOTICES

    makeWrapper "$out/libexec/herdr-app" "$out/bin/herdr-app" \
      --prefix PATH : ${lib.makeBinPath [ herdr-core ]} \
      --suffix PATH : ${
        lib.makeBinPath [
          git
          xdg-utils
        ]
      }

    runHook postInstall
  '';

  doInstallCheck = stdenv.buildPlatform.canExecute stdenv.hostPlatform;
  installCheckPhase = ''
    runHook preInstallCheck
    test "$("$out/bin/herdr-app" --version)" = "herdr-app ${finalAttrs.version}"
    runHook postInstallCheck
  '';

  meta = {
    description = "Desktop app for terminals and coding agents";
    homepage = "https://github.com/herdrdev/herdr-app";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "herdr-app";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
