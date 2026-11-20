# ADA Density Explorer

An interactive page for learning physical density by moving sliders and watching the picture move with the numbers. Every calculation is Plain Ada, compiled to WebAssembly. HTML and CSS draw the page. JavaScript only loads the module, wires the controls, and paints the figures.

The page is one file, [`index.html`](index.html), plus [`density.wasm`](density.wasm). Paths are relative, so it can be opened from a static host with no build step.

## Live page

https://raw.githack.com/RobertBoettcherSF/ada-density-explorer/main/index.html

A browser may meet raw.githack’s confirmation screen first. After that, the page loads `density.wasm` from the same directory. It uses `WebAssembly.instantiate` on the fetched bytes, so it still runs when the host does not label the file `application/wasm`.

## What is on the page

1. **Float tank.** Preset solids and fluids, or your own mass and volume. The block settles at the submerged fraction ρ_object / ρ_fluid, or it sinks. Weight, buoyant force and apparent weight are shown.
2. **Pack the box.** Count, particle mass and box size. The gaps change only when the packing changes. Mass can change while the gaps stay put.
3. **Same size, different weight.** Equal volumes on a balance. The heavier side goes down.
4. **Density ladder.** A logarithmic scale from interstellar space to a neutron star, with zoom. A 5 mL teaspoon is compared with familiar masses.
5. **Mostly empty.** Zoom from a solid object to a Bohr atom to a proton. The nucleus-to-atom volume fraction, and the radius of the Earth compressed to nuclear density, are computed in Ada.
6. **Imagine.** Labelled as a thought experiment, separate from the measurements above. Approximate solar-neutrino and dark-matter figures, then an open question inspired by near-death-experience accounts. The question is not offered as a physics result.

Figures that are conventions or orders of magnitude are marked on the page. Sources are listed under Sources at the bottom.

## Build

The toolchain matches [ada-technological-horizons](https://github.com/RobertBoettcherSF/ada-technological-horizons): AdaWebPack 24.0.0 (GNAT-LLVM, `llvm-gcc`) and Ubuntu’s `wasm-ld` from LLVM 16. The verified host is Ubuntu 24.04.

```bash
sudo apt-get install gnat llvm-16 lld-16 curl ca-certificates python3
bash tools/build.sh
```

`tools/build.sh` downloads AdaWebPack 24.0.0, checks its SHA-256 (`8edaae8b9987a20aec430d750f30033f12f953ce2b6437afb87fbf8cc1063796`), runs the native smoke test, links `density.wasm`, and runs the same checks inside the Wasm module with Node.

`llvm-gcc` links by calling the system `clang`. Clang 18 looks for a program named `wasm-ld-18`. The script points that name at LLVM 16’s `wasm-ld`, which is the linker AdaWebPack 24.0.0 was built with.

Serve the directory that contains `index.html` and `density.wasm`:

```bash
python3 -m http.server 8765
```

Open `http://127.0.0.1:8765/`.

## Smoke test

```bash
bash tools/build.sh
```

The native program `tests/native/density_smoke.adb` checks water at 1000 kg/m³, ice at 917 kg/m³ floating in that water with submerged fraction 0.917, and the same ice sinking in ethanol at 789 kg/m³. It also checks sea water at 1025, mercury at 13534, iron floating in mercury, a packed box, the balance, a teaspoon of water, and that an Earth compressed to nuclear density is a few hundred metres across. `tools/smoke.mjs` repeats the main cases against `density.wasm`.

## Layout

- `ada/core/density.adb` — the calculations and the constants they use.
- `ada/browser/` — the fixed-width exports the page calls.
- `tests/native/density_smoke.adb` — the native smoke test.
- `tools/build.sh` — download, native test, Wasm link.
- `tools/smoke.mjs` — the Wasm smoke test. No packages.
- `index.html` — the page.
- `density.wasm` — the compiled module the page fetches.

## Runtime licence

No licence is selected for the original Ada, HTML, CSS or JavaScript in this repository. The compiled `density.wasm` also contains the GNAT WebAssembly run-time from AdaWebPack, which is covered by the GNU General Public License with the GCC Runtime Library Exception. That exception applies to the embedded run-time, not to the original source.
