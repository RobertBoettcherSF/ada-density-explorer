#!/usr/bin/env bash
# Build the native smoke check and the WebAssembly module.
# Same route as ada-technological-horizons: AdaWebPack 24.0.0, GNAT-LLVM,
# and Ubuntu's wasm-ld from LLVM 16.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

ADAWEBPACK_URL="https://github.com/godunko/adawebpack/releases/download/24.0.0/adawebpack-24.0.0.tar.gz"
ADAWEBPACK_SHA256="8edaae8b9987a20aec430d750f30033f12f953ce2b6437afb87fbf8cc1063796"
TOOLCHAIN="${DENSITY_ADAWEBPACK:-$ROOT/toolchain/adawebpack}"
CACHE="$ROOT/toolchain/adawebpack-24.0.0.tar.gz"

if ! command -v gnatmake >/dev/null; then
  echo "gnatmake is required (Ubuntu package: gnat)." >&2
  exit 1
fi
if ! command -v curl >/dev/null || ! command -v sha256sum >/dev/null; then
  echo "curl and sha256sum are required." >&2
  exit 1
fi

mkdir -p "$ROOT/toolchain" "$ROOT/build/native" "$ROOT/build/wasm"

if [[ ! -x "$TOOLCHAIN/bin/llvm-gcc" ]]; then
  if [[ ! -f "$CACHE" ]]; then
    echo "Downloading AdaWebPack 24.0.0…"
    curl -fL --retry 3 -o "$CACHE.partial" "$ADAWEBPACK_URL"
    mv "$CACHE.partial" "$CACHE"
  fi
  echo "$ADAWEBPACK_SHA256  $CACHE" | sha256sum -c -
  tar -xzf "$CACHE" -C "$ROOT/toolchain"
fi

if [[ ! -x "$TOOLCHAIN/bin/llvm-gcc" ]]; then
  echo "AdaWebPack llvm-gcc was not found at $TOOLCHAIN/bin/llvm-gcc" >&2
  exit 1
fi

WASM_LD_BIN=""
for candidate in \
  "${WASM_LD:-}" \
  /usr/lib/llvm-16/bin/wasm-ld \
  /usr/bin/wasm-ld-16 \
  /usr/bin/wasm-ld
do
  if [[ -n "$candidate" && -x "$candidate" ]]; then
    WASM_LD_BIN="$candidate"
    break
  fi
done
if [[ -z "$WASM_LD_BIN" ]]; then
  echo "wasm-ld is required (Ubuntu packages: llvm-16 and lld-16)." >&2
  exit 1
fi
# llvm-gcc links by calling the system clang driver. Clang 18 looks for an
# executable named wasm-ld-18. The objects are produced by AdaWebPack's
# LLVM 16 tools, so that name is pointed at the pinned LLVM 16 wasm-ld.
LINK_DIR="$ROOT/toolchain/link"
mkdir -p "$LINK_DIR"
ln -sfn "$WASM_LD_BIN" "$LINK_DIR/wasm-ld-18"
ln -sfn "$WASM_LD_BIN" "$LINK_DIR/wasm-ld"
export PATH="$LINK_DIR:$(dirname "$WASM_LD_BIN"):$TOOLCHAIN/bin:$PATH"

echo "Native GNAT: $(gnatmake --version | head -n 1)"
echo "Wasm compiler: $("$TOOLCHAIN/bin/llvm-gcc" -v 2>&1 | tail -n 1)"
echo "Linker: $WASM_LD_BIN ($("$WASM_LD_BIN" --version | head -n 1))"

rm -rf "$ROOT/build/native" "$ROOT/build/wasm"
mkdir -p "$ROOT/build/native" "$ROOT/build/wasm"

gnatmake -D "$ROOT/build/native" -o "$ROOT/build/native/density_smoke" \
  "$ROOT/tests/native/density_smoke.adb" \
  -I"$ROOT/ada/core"
"$ROOT/build/native/density_smoke"

compile_wasm() {
  local Source="$1"
  local Object="$2"
  "$TOOLCHAIN/bin/llvm-gcc" -c -x ada "$Source" \
    --target=wasm32 -gnatA -I"$ROOT/ada/core" -I"$ROOT/ada/browser" \
    -o "$ROOT/build/wasm/$Object"
}

compile_wasm "$ROOT/ada/core/density.adb" density.o
compile_wasm "$ROOT/ada/browser/density_exports.adb" density_exports.o
compile_wasm "$ROOT/ada/browser/density_browser.ads" density_browser.o

(
  cd "$ROOT/build/wasm"
  "$TOOLCHAIN/bin/llvm-gnatbind" -n density_browser.ali \
    -I"$ROOT/ada/core" -I"$ROOT/ada/browser"
  "$TOOLCHAIN/bin/llvm-gcc" -c -x ada b~density_browser.adb \
    --target=wasm32 -gnatA -I"$ROOT/ada/core" -I"$ROOT/ada/browser" \
    -o b~density_browser.o
  "$TOOLCHAIN/bin/llvm-gcc" --target=wasm32 -o density.wasm \
    density.o density_exports.o density_browser.o b~density_browser.o \
    -L"$TOOLCHAIN/lib/rts-native/adalib" -lgnat \
    -nostdlib \
    -Wl,--no-entry \
    -Wl,--allow-undefined \
    -Wl,--gc-sections \
    -Wl,--export=adainit \
    -Wl,--export=adafinal \
    -Wl,--export=density_run \
    -Wl,--export=density_out \
    -Wl,--export=density_count \
    -Wl,--export-memory
)

cp "$ROOT/build/wasm/density.wasm" "$ROOT/density.wasm"
echo "wasm ready: $ROOT/density.wasm"
echo "wasm sha256: $(sha256sum "$ROOT/density.wasm" | awk '{print $1}')"

if command -v node >/dev/null; then
  node "$ROOT/tools/smoke.mjs" "$ROOT/density.wasm"
fi
