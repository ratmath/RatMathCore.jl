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

The package is currently an implementation seed: it has a working core, representative tests, and
documentation, but it is not yet a complete behavioral clone of the JavaScript package.

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
- Continued fractions and convergents.

Remaining work:

- Expand test coverage to every target in `test-design.md`.
- Tighten decimal and scientific notation parity with JavaScript edge cases.
- Add compact and relative decimal interval notation.
- Add more docstrings and doctests as behavior stabilizes.

