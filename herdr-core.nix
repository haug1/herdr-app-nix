{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "herdr-core";
  version = "0.1.22";

  src = fetchurl {
    url = "https://releases.herdr.dev/core/${finalAttrs.version}/herdr-core-linux-${stdenvNoCC.hostPlatform.parsed.cpu.name}.tar.gz";
    hash =
      {
        x86_64-linux = "sha256-MFTsOZLOgMVxXXIcqp3O+mBWch0V3BE/R1CvznY7pd8=";
        aarch64-linux = "sha256-mHV5hSRdRfjXPdheaLE5t/FnwoSIu4nt2YNMP1pc9M8=";
      }
      .${stdenvNoCC.hostPlatform.system};
  };

  sourceRoot = ".";
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 herdr-core "$out/bin/herdr-core"
    ln -s herdr-core "$out/bin/hc"
    install -Dm644 -t "$out/share/licenses/herdr-core" LICENSE THIRD-PARTY-NOTICES

    runHook postInstall
  '';

  doInstallCheck = stdenvNoCC.buildPlatform.canExecute stdenvNoCC.hostPlatform;
  installCheckPhase = ''
    runHook preInstallCheck
    test "$("$out/bin/hc" --version)" = "hc ${finalAttrs.version}"
    runHook postInstallCheck
  '';

  meta = {
    description = "Persistent terminals for coding agents";
    homepage = "https://github.com/herdrdev/herdr-core";
    license = lib.licenses.asl20;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "hc";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
})
