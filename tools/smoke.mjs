// Loads the committed Wasm module and checks the same teaching cases as
// tests/native/density_smoke.adb. No dependencies.
import { readFileSync } from "node:fs";

const file = process.argv[2] ?? "density.wasm";
const bytes = readFileSync(file);
const holder = { instance: null };
const { instance } = await WebAssembly.instantiate(bytes, {
  env: {
    __gnat_put_exception() {
      throw new Error("Ada runtime reported an exception");
    },
    __gnat_grow(pages) {
      const memory = holder.instance?.exports?.memory;
      if (!memory) return -1;
      try {
        return memory.grow(pages);
      } catch {
        return -1;
      }
    },
  },
});
holder.instance = instance;
const ex = instance.exports;
if (typeof ex.adainit !== "function" || typeof ex.density_run !== "function") {
  throw new Error("Ada exports are missing");
}
ex.adainit();

let failed = 0;
function check(name, cond) {
  if (cond) {
    console.log("PASS", name);
  } else {
    console.log("FAIL", name);
    failed += 1;
  }
}
function near(left, right, tol) {
  return Math.abs(left - right) <= tol;
}
function run(op, a = 0, b = 0, c = 0, d = 0) {
  const status = ex.density_run(op, a, b, c, d);
  const n = ex.density_count();
  const out = [];
  for (let i = 1; i <= n; i += 1) out.push(ex.density_out(i));
  return { status, out };
}

const water = run(1, 4);
const ice = run(1, 3);
const ethanol = run(2, 1);
const sea = run(2, 4);
const mercury = run(2, 6);
check("wasm water 1000", water.status === 0 && water.out[0] === 1000);
check("wasm ice 917", ice.status === 0 && ice.out[0] === 917);
check("wasm ethanol 789", ethanol.status === 0 && ethanol.out[0] === 789);
check("wasm sea water 1025", sea.status === 0 && sea.out[0] === 1025);
check("wasm mercury 13534", mercury.status === 0 && mercury.out[0] === 13534);

const floating = run(3, 3, 0, 0.001, 1000);
check("wasm ice floats", floating.status === 0 && floating.out[9] === 1);
check("wasm ice 91.7 percent", floating.status === 0 && near(floating.out[14], 91.7, 1e-9));
check("wasm floating apparent weight 0", near(floating.out[6], 0, 1e-9));

const sunk = run(3, 3, 0, 0.001, 789);
check("wasm ice sinks in ethanol", sunk.status === 0 && sunk.out[9] === 2);
check("wasm sunk apparent weight", sunk.out[6] > 0);

const iron = run(3, 6, 0, 0.001, 13534);
check("wasm iron floats in mercury", iron.status === 0 && iron.out[9] === 1);

const spoon = run(8, 3, 40);
check("wasm teaspoon of water", spoon.status === 0 && near(spoon.out[2], 0.005, 1e-9));
check("wasm teaspoon anchor is a paperclip", spoon.out[3] === 4);

if (failed) {
  console.log("WASM SMOKE FAILED");
  process.exit(1);
}
console.log("WASM SMOKE PASSED");
