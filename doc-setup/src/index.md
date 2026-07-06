# RatMathCore.jl

RatMathCore.jl is a Julia port of the useful exact-arithmetic behavior from RatMath's JavaScript
`packages/core` package.

The port intentionally uses Julia's native exact number types:

- `BigInt` for arbitrary-precision integers.
- `Rational{BigInt}` for reduced exact rational numbers.
- Custom types for RatMath-specific behavior:
  - [`RationalInterval`](@ref)
  - [`Fraction`](@ref)
  - [`FractionInterval`](@ref)
  - [`BaseSystem`](@ref)

The planned porting scope is implemented: the package has a working core, JavaScript RatMath parity
samples for high-risk formatting behavior, expanded tests, and Documenter.jl documentation.

## Core Ideas

RatMathCore.jl keeps exactness as the default. Values such as ``1/3`` are represented exactly as
`1//3`, and interval endpoints are exact rationals.

```@example quickstart
using RatMathCore

rat("5..2/3")
```

```@example quickstart
repeating_decimal(1//7)
```

```@example quickstart
RationalInterval(1, 2) + RationalInterval(3, 4)
```

## Package Status

Implemented:

- RatMath-style rational construction.
- Exact interval arithmetic over rationals.
- Unreduced fractions for mediants, Farey triples, and Stern-Brocot paths.
- Custom base systems and repeating expansions.
- Scientific notation matched against representative JavaScript RatMath outputs.
- Continued fractions and convergents.
- Compact and relative decimal interval notation.
- Documenter.jl source under `doc-setup/` and GitHub Pages-ready HTML under `docs/`.

Maintenance focus:

- Add more property tests for very large values as new edge cases are discovered.
- Broaden `test/js-parity-samples.mjs` when RatMath JS formatting behavior changes.

