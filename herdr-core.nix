{
  lib,
  stdenvNoCC,
  fetchurl,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "herdr-core";
  version = "0.1.22";

  src = fetchurl {
    url = "https://releases.herdr.dev/core/${finalAttrs.version}/herdr-core-linux-x86_64.tar.gz";
    sha256 = "3054ec3992ce80c5715d721caa9dcefa6056721d15dc113f4750afce763ba5df";
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
    platforms = [ "x86_64-linux" ];
  };
})
