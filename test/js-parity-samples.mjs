import assert from "node:assert/strict";
import { Rational, RationalInterval } from "../../packages/core/index.js";

const scientificSamples = new Map([
  ["0", "0"],
  ["123", "1.23E2"],
  ["1000", "1E3"],
  ["1200", "1.2E3"],
  ["1/1000", "1E-3"],
  ["1/3", "3.#3E-1 {period: 1}"],
  ["-1/8", "-1.25E-1"],
  ["1/7", "1.#42857E-1 {period: 6}"],
  ["1/6", "1.#6E-1 {period: 1}"],
  ["22/7", "3.#142857E0 {period: 6}"],
  ["1/28", "3.#571428E-2 {initial: 1 zeros, period: 6}"],
  ["1/12", "8.#3E-2 {initial: 1 zeros, period: 1}"],
  ["1/90", "1.#1E-2 {initial: 1 zeros, period: 1}"],
  ["100/33", "3.#03E0 {period starts: +1 zeros, period: 2}"],
  ["12345/28", "4.4089#285714E2 {period: 6}"],
  ["1/100000000", "1E-8"],
]);

for (const [source, expected] of scientificSamples) {
  const actual = new Rational(source).toScientificNotation(true, 11, true);
  assert.equal(actual, expected, `scientific notation for ${source}`);
}

const intervalSamples = [
  {
    low: "1224/1000",
    high: "1235/1000",
    compact: "1.2[24,35]",
    mid: "1.2295[+-0.0055]",
    relative: "1.23[+5,-6]",
  },
  {
    low: "12356/10000",
    high: "12367/10000",
    compact: "1.23[56,67]",
    mid: "1.23615[+-0.00055]",
    relative: "1.236[+7,-4]",
  },
];

for (const sample of intervalSamples) {
  const interval = new RationalInterval(new Rational(sample.low), new Rational(sample.high));
  assert.equal(interval.compactedDecimalInterval(), sample.compact, `compact interval ${sample.low}:${sample.high}`);
  assert.equal(interval.relativeMidDecimalInterval(), sample.mid, `relative midpoint interval ${sample.low}:${sample.high}`);
  assert.equal(interval.relativeDecimalInterval(), sample.relative, `relative interval ${sample.low}:${sample.high}`);
}

console.log("JS RatMath parity samples passed.");
