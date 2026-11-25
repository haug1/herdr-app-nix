{
  runCommand,
  herdr-app,
  herdr-core,
  jq,
  mesa,
  runtimeShell,
  weston,
}:

runCommand "herdr-smoke-test"
  {
    nativeBuildInputs = [
      herdr-app
      herdr-core
      jq
      weston
    ];
    env.VK_DRIVER_FILES = "${mesa}/share/vulkan/icd.d/lvp_icd.x86_64.json";
  }
  ''
    set -o pipefail

    export HOME="$PWD/home"
    export XDG_RUNTIME_DIR="$PWD/run"
    export WAYLAND_DISPLAY=herdr-smoke
    export XDG_SESSION_TYPE=wayland
    export HC_SOCKET="$XDG_RUNTIME_DIR/hc.sock"
    export HERDR_TELEMETRY=0
    export SHELL=${runtimeShell}
    mkdir "$HOME"
    mkdir -m 700 "$XDG_RUNTIME_DIR"

    cleanup() {
      local result=$?
      if [[ -v app_pid ]]; then kill "$app_pid" 2>/dev/null || true; fi
      if [[ -S "$HC_SOCKET" ]]; then timeout 5s hc server stop >/dev/null 2>&1 || true; fi
      if [[ -v weston_pid ]]; then kill "$weston_pid" 2>/dev/null || true; fi
      if (( result != 0 )); then cat weston.log herdr-app.log >&2 || true; fi
    }
    trap cleanup EXIT

    wait_for() {
      local deadline=$((SECONDS + 30))
      until "$@" >/dev/null 2>&1; do
        if (( SECONDS >= deadline )); then
          echo "Timed out waiting for $*" >&2
          return 1
        fi
        sleep 0.2
      done
    }

    # Herdr needs a Wayland seat even without physical input devices.
    weston --backend=headless --renderer=pixman --shell=kiosk --fake-seat --no-config \
      --socket="$WAYLAND_DISPLAY" >weston.log 2>&1 &
    weston_pid=$!
    wait_for test -S "$XDG_RUNTIME_DIR/$WAYLAND_DISPLAY"

    herdr-app >herdr-app.log 2>&1 &
    app_pid=$!
    wait_for timeout 2s herdr-app status

    argv=$(jq -cn --arg shell "$SHELL" '[$shell, "-c", "printf \"herdr-smoke-ok\\n\"; exec sleep 60"]')
    terminal=$(timeout 10s herdr-app do space.new --name smoke --folder "$HOME" --argv "$argv" \
      | jq -er '.terminal | strings | select(length > 0)')

    terminal_output_is_visible() {
      timeout 2s hc read "$terminal" | grep -F 'herdr-smoke-ok'
    }
    wait_for terminal_output_is_visible
    touch "$out"
  ''
