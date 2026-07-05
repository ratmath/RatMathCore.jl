# Agent Instructions for RatMath Julia Port

Use this folder as the seed documentation for a new Julia repository. Do not add Julia implementation code to this folder inside the RatMath monorepo unless explicitly asked.

## Source of Truth

The JavaScript source in `packages/core/src/` is the behavior reference:

- `integer.js` - RatMath-style integer wrapper and promotion behavior.
- `rational.js` - reduced rational parsing, formatting, decimal expansion, continued fractions.
- `rational-interval.js` - exact closed intervals over rationals.
- `fraction.js` - unreduced fractions, mediants, Farey and Stern-Brocot helpers.
- `fraction-interval.js` - intervals over unreduced fractions.
- `base-system.js` - digit alphabets, prefixes, and arbitrary-base conversion.
- `type-promotion.js` - old JS promotion helper; adapt the behavior into Julia dispatch rather than cloning this class literally.

The existing JS tests in `packages/core/tests/` are useful examples, but the Julia package should be idiomatic. Preserve externally meaningful behavior, not JavaScript implementation details.

## Porting Policy

- Use Julia `BigInt` and `Rational{BigInt}` internally.
- Prefer Julia methods and operators over JavaScript-style method-only APIs.
- Provide RatMath-named compatibility methods where they make examples clearer.
- Keep unreduced `Fraction` separate from reduced Julia rationals.
- Preserve exactness. Avoid `Float64` except for explicitly approximate display helpers or bounded estimates where the design calls that out.
- Treat decimal/repeating/base formatting as first-class behavior, not incidental string output.
- Do not implement RiX parser behavior in this package. This port targets `packages/core`, not `rix/`.

## Expected New Repo Shape

Recommended package name: `RatMathCore.jl`.

Recommended layout:

```text
RatMathCore.jl/
├── Project.toml
├── src/
│   ├── RatMathCore.jl
│   ├── fractions.jl
│   ├── intervals.jl
│   ├── bases.jl
│   ├── decimal_format.jl
│   ├── continued_fractions.jl
│   └── compatibility.jl
├── test/
│   ├── runtests.jl
│   ├── rational_tests.jl
│   ├── interval_tests.jl
│   ├── fraction_tests.jl
│   ├── base_tests.jl
│   └── formatting_tests.jl
└── docs/
```

## Implementation Order

Follow the phases in `design.md`. Build and test one behavior group at a time. Do not start with the decimal formatter; it depends on stable rational and base-system behavior.

## Completion Criteria

The port is ready for first use when:

- All test targets in `test-design.md` have corresponding Julia tests.
- Public methods are documented with docstrings.
- Examples cover exact arithmetic, interval arithmetic, unreduced fractions, repeating decimals, bases, and continued fractions.
- The package passes `julia --project -e 'using Pkg; Pkg.test()'`.
