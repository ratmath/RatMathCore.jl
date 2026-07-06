# RatMath Core Julia Port Design

## Implementation Status

As of July 6, 2026, the planned implementation phases in this design are complete for the
`RatMathCore.jl` package in this repository. The package includes the exact-rational helpers,
`RationalInterval`, unreduced `Fraction` and `FractionInterval`, `BaseSystem`, repeating decimal
and arbitrary-base expansion, scientific notation with representative JavaScript RatMath parity,
continued fractions, Documenter.jl source under `doc-setup/`, and built GitHub Pages documentation
under `docs/`.

The active remaining work is maintenance hardening: broadening parity samples when JavaScript
`packages/core` behavior changes, adding more property tests for very large values, and deciding
whether future CI should rebuild `docs/` or treat it as a committed artifact.

## Purpose

Create a Julia package that ports the useful behavior of RatMath `packages/core` while using Julia's native exact-number strengths. The port should not be a line-by-line translation. It should preserve RatMath's mathematical behavior, notation, and user-facing examples where they are valuable, while using Julia dispatch, operators, parametric types, and package conventions.

Recommended package name: `RatMathCore.jl`.

## Non-Goals

- Do not port the legacy calculator, `VariableManager`, or old parser packages.
- Do not port RiX parser/evaluator behavior into this package.
- Do not implement transcendental real-number oracle behavior unless a later design explicitly expands scope.
- Do not wrap every Julia integer in a custom `Integer` type unless compatibility demands it.
- Do not make JavaScript private fields, class layout, or error text part of the contract.

## Existing JavaScript Scope

The current JS package exports:

- `Integer` - BigInt-backed exact integer wrapper.
- `Rational` - reduced exact rational numbers.
- `RationalInterval` - exact closed intervals over rationals.
- `Fraction` - unreduced numerator/denominator pairs, including limited infinite sentinels for Stern-Brocot boundaries.
- `FractionInterval` - closed intervals over unreduced fractions.
- `BaseSystem` - custom digit alphabets, registered prefixes, base conversion.
- `TypePromotion` - promotion helper for the JS class hierarchy.

The JS source is about 5,600 lines with about 3,600 lines of tests. Most mathematical primitive behavior already exists in Julia; the important porting work is the RatMath-specific behavior around exact intervals, unreduced fractions, custom notation, and arbitrary digit alphabets.

## Julia Foundation

Use Julia built-ins as the foundation:

- `BigInt` for arbitrary precision integers.
- `Rational{BigInt}` for reduced exact rationals.
- `//` for rational construction in idiomatic APIs.
- `gcd`, `lcm`, `factorial`, `abs`, `sign`, `iszero`, `iseven`, `isodd`, comparison operators, and exponentiation from Base.
- Multiple dispatch for mixed arithmetic instead of a `TypePromotion` class.

The package may expose helper constructors so users can write RatMath-like examples without losing Julia idioms.

## Public API Overview

Export these core names:

```julia
module RatMathCore

export rat, mixed, e_notation
export RationalInterval, point_interval
export Fraction, FractionInterval
export BaseSystem
export repeating_decimal, repeating_decimal_with_period
export scientific_notation
export continued_fraction, from_continued_fraction
export continued_fraction_string, from_continued_fraction_string
export convergents, best_approximation

end
```

Avoid exporting names that conflict strongly with Julia Base unless there is a clear benefit.

## Numeric Representation

### Integers

Do not define a new `Integer` type in the first implementation. Julia already has `Integer` as an abstract type and `BigInt` as the arbitrary-precision implementation. Creating a concrete `Integer` wrapper would fight Julia conventions.

Provide compatibility helpers:

```julia
bigint(x) -> BigInt
rat(x) -> Rational{BigInt}
e_notation(x::Integer, exponent::Integer)
bit_length(x::Integer)
double_factorial(n::Integer)
```

RatMath JS behavior to preserve where practical:

- Exact integer arithmetic stays exact.
- Integer division in compatibility helpers can return `BigInt` when exact and `Rational{BigInt}` when not exact.
- Negative integer powers return rationals when mathematically valid.
- `0^0` should throw in compatibility helpers matching RatMath, even though Julia's Base behavior may differ.

### Reduced Rationals

Use `Rational{BigInt}` directly. This gives normalized sign, reduced numerator/denominator, exact arithmetic, and comparison.

Provide constructors:

```julia
rat(n::Integer) -> Rational{BigInt}
rat(n::Integer, d::Integer) -> Rational{BigInt}
rat(s::AbstractString) -> Rational{BigInt}
mixed(whole::Integer, numerator::Integer, denominator::Integer)
```

String parsing should support:

- Integers: `"5"`, `"-12"`.
- Fractions: `"3/4"`, `"-10/7"`.
- Mixed numbers: `"5..2/3"`, `"-2..1/4"`.
- Terminating decimals: `"1.25"`, `"-0.125"`.
- RatMath compact repeated digits inside decimal strings, such as `"0.{0~8}1"` if needed for roundtrip support.

Core methods:

```julia
to_mixed_string(x::Rational{BigInt})::String
to_decimal(x::Rational{BigInt}; maxdigits::Integer=20)::String
repeating_decimal(x::Rational{BigInt}; compact::Bool=true)::String
repeating_decimal_with_period(x::Rational{BigInt}; compact::Bool=true)::NamedTuple
period_modulo(x::Rational{BigInt}, base::BaseSystem; limit::Integer=1_000_000)::Int
scientific_notation(x::Rational{BigInt}; compact::Bool=true, precision::Integer=11, show_period_info::Bool=false)::String
```

Use `numerator(x)` and `denominator(x)` internally rather than storing a custom rational type.

### Exact Rational Intervals

Define:

```julia
struct RationalInterval
    start::Rational{BigInt}
    stop::Rational{BigInt}
    low::Rational{BigInt}
    high::Rational{BigInt}
end
```

The constructor should preserve the original endpoint order in `start` and `stop`, while also computing ordered `low` and `high`. This matches the JS behavior where `toString()` uses the original order but mathematical operations use ordered bounds.

Constructors:

```julia
RationalInterval(a, b)
point_interval(x)
parse_interval(s::AbstractString)
```

Operators and methods:

```julia
+(a::RationalInterval, b)
-(a::RationalInterval, b)
*(a::RationalInterval, b)
/(a::RationalInterval, b)
-(a::RationalInterval)
recip(a::RationalInterval)
contains(a::RationalInterval, x)
contains_zero(a::RationalInterval)
overlaps(a::RationalInterval, b::RationalInterval)
intersection(a::RationalInterval, b::RationalInterval)
union(a::RationalInterval, b::RationalInterval)
midpoint(a::RationalInterval)
mediant(a::RationalInterval)
shortest_decimal(a::RationalInterval; base::Integer=10)
random_rational(a::RationalInterval; max_denominator::Integer=1000, rng=Random.default_rng())
```

Power behavior must distinguish two concepts:

- `pow_interval(a, n)` maps the power function over all values in the interval and encloses the result. For even powers across zero, the low bound is zero.
- `mpow_interval(a, n)` multiplies the interval by itself repeatedly. This is dependency-preserving interval multiplication and can be wider than pointwise power.

Do not overload `^` until the package has a clear policy. If overloaded, document whether it means pointwise power or multiplicative interval power.

### Unreduced Fractions

Define:

```julia
struct Fraction
    num::BigInt
    den::BigInt
    infinite::Bool
end
```

The constructor should not reduce finite fractions. Denominator zero is allowed only for `1//0` and `-1//0` sentinels when explicitly requested.

Recommended constructors:

```julia
Fraction(n::Integer, d::Integer=1; allow_infinite::Bool=false)
Fraction(s::AbstractString; allow_infinite::Bool=false)
```

Behavior:

- Equality is representation equality: `Fraction(1, 2) != Fraction(2, 4)`.
- Comparisons use cross multiplication for finite values.
- `reduce_fraction(f)` returns a reduced `Fraction`.
- `rational(f)` converts to `Rational{BigInt}` and reduces.
- Addition/subtraction require equal denominators, preserving RatMath behavior.
- Multiplication/division/powers preserve direct numerator/denominator operations.
- `e_notation(f, exponent)` shifts numerator or denominator by powers of ten.

Mediant and tree helpers:

```julia
mediant(a::Fraction, b::Fraction)::Fraction
farey_parents(f::Fraction)::NamedTuple
mediant_partner(endpoint::Fraction, mediant::Fraction)::Fraction
is_mediant_triple(left, med, right)::Bool
is_farey_triple(left, med, right)::Bool
stern_brocot_path(f::Fraction)::Vector{Char}
from_stern_brocot_path(path)::Fraction
stern_brocot_parent(f::Fraction)
stern_brocot_children(f::Fraction)::NamedTuple
stern_brocot_depth(f::Fraction)
stern_brocot_ancestors(f::Fraction)::Vector{Fraction}
```

### Fraction Intervals

Define:

```julia
struct FractionInterval
    low::Fraction
    high::Fraction
end
```

The constructor orders endpoints by numeric value but preserves unreduced endpoint representations.

Methods:

```julia
mediant_split(i::FractionInterval)::Tuple{FractionInterval,FractionInterval}
partition_with_mediants(i::FractionInterval, depth::Integer=1)::Vector{FractionInterval}
partition_with(i::FractionInterval, fn)::Vector{FractionInterval}
rational_interval(i::FractionInterval)::RationalInterval
fraction_interval(i::RationalInterval)::FractionInterval
e_notation(i::FractionInterval, exponent::Integer)::FractionInterval
```

### Base Systems

Define:

```julia
struct BaseSystem
    chars::Vector{String}
    charmap::Dict{String,Int}
    name::String
end
```

Keep digit values zero-based to match numeral systems. `get_char(base, value)` returns the character for an integer digit value.

Features:

- Construct from string or vector of single-character strings.
- Reject duplicate characters.
- Reject reserved parser symbols: `+ - * / ^ ! ( ) [ ] : . # ~`.
- Warn or reject suspicious large bases according to package policy.
- Convert integers to and from arbitrary digit alphabets.
- Validate strings.
- Presets for binary, ternary, quaternary, quinary, septenary, octal, decimal, duodecimal, hexadecimal, vigesimal, base36, base60, base62, base64, and roman-character alphabets.
- Prefix registration and lookup, preserving the JS rule that uppercase `D` is reserved.

Recommended methods:

```julia
base_system(base::Integer; name=nothing)::BaseSystem
create_base_pattern(pattern::Symbol, size::Integer; name=nothing)::BaseSystem
to_decimal(system::BaseSystem, s::AbstractString)::BigInt
from_decimal(system::BaseSystem, value::Integer)::String
valid_digit_string(system::BaseSystem, s::AbstractString)::Bool
with_case_sensitivity(system::BaseSystem, case_sensitive::Bool)::BaseSystem
register_prefix!(prefix::AbstractString, system::BaseSystem)
unregister_prefix!(prefix::AbstractString)
system_for_prefix(prefix::AbstractString)
prefix_for_system(system::BaseSystem)
```

### Repeating Expansions and Decimal Formatting

This is a core RatMath feature and should be treated as a separate module.

Support decimal notation:

- Terminating decimals: `1/2 -> "0.5#0"` for repeating-decimal output.
- Repeating decimals: `1/3 -> "0.#3"`.
- Negative numbers: `-1/6 -> "-0.1#6"`.
- Compact repeated runs: use `{digit~count}` when count is above the configured threshold.
- Period metadata: return both display string and exact period length when known.

Support arbitrary-base repeating expansions:

```julia
repeating_base(x::Rational{BigInt}, system::BaseSystem; compact::Bool=true, limit::Integer=1000)::String
repeating_base_with_period(x::Rational{BigInt}, system::BaseSystem; compact::Bool=true, limit::Integer=1000)::NamedTuple
```

Cycle detection should use a remainder map for display generation. Period length can be computed by multiplicative order after removing denominator factors shared with the base.

### Continued Fractions

Implement continued fractions for `Rational{BigInt}`:

```julia
continued_fraction(x::Rational{BigInt}; max_terms::Integer=1000)::Vector{BigInt}
from_continued_fraction(terms)::Rational{BigInt}
continued_fraction_string(x::Rational{BigInt})::String
from_continued_fraction_string(s::AbstractString)::Rational{BigInt}
convergents(x::Rational{BigInt}; max_count::Integer=1000)::Vector{Rational{BigInt}}
convergents_from_cf(input; max_count::Integer=1000)
approximation_error(x::Rational{BigInt}, target::Rational{BigInt})
best_approximation(x::Rational{BigInt}, max_denominator::Integer)
```

Preserve canonicalization: continued fractions should not end with a final `1` unless it is the only valid representation.

### Promotion and Dispatch

Do not port `TypePromotion` literally. Use Julia methods:

```julia
promote_rule(::Type{RationalInterval}, ::Type{Rational{BigInt}})
promote_rule(::Type{RationalInterval}, ::Type{BigInt})
```

Because `RationalInterval` is not a subtype of `Number` unless carefully designed, start conservatively. Implement explicit methods for:

- `RationalInterval` with integers.
- `RationalInterval` with `Rational{BigInt}`.
- `FractionInterval` with `Fraction` where needed.

Only subtype `Number` after verifying that Base arithmetic, promotion, `zero`, `one`, and conversion semantics are coherent.

## Error Policy

Use Julia exception types:

- `ArgumentError` for invalid formats or invalid constructor arguments.
- `DivideError` or `DomainError` for division by zero, reciprocal of zero, and invalid powers.
- `BoundsError` for invalid digit lookups when appropriate.

Do not require exact JavaScript error text. Tests should check error type and broad reason.

## File Layout

Recommended source files:

```text
src/RatMathCore.jl
src/compatibility.jl
src/fractions.jl
src/intervals.jl
src/bases.jl
src/decimal_format.jl
src/continued_fractions.jl
```

`RatMathCore.jl` should include files in dependency order:

1. `bases.jl`
2. `compatibility.jl`
3. `decimal_format.jl`
4. `continued_fractions.jl`
5. `fractions.jl`
6. `intervals.jl`

Adjust this order if actual dependencies differ. Keep circular dependencies out of the design.

## Documentation Plan

Add docstrings for every exported function and type. Include examples for:

- Exact integer and rational arithmetic.
- Interval arithmetic.
- Difference between `Rational{BigInt}` and unreduced `Fraction`.
- Repeating decimals.
- Arbitrary-base display.
- Continued fractions.
- Stern-Brocot and Farey helpers.

## Implementation Phases

### Phase 1: Julia Package Skeleton

- Create `Project.toml`.
- Create module and source layout.
- Add `test/runtests.jl`.
- Add CI later if desired.

Completion: package loads with `using RatMathCore`.

### Phase 2: Basic Exact Helpers

- Implement `rat`, mixed-number parsing, `to_mixed_string`, `e_notation`, `bit_length`, and `double_factorial`.
- Add rational parsing for integers, fractions, mixed numbers, and terminating decimals.

Completion: basic rational examples in `test-design.md` work.

### Phase 3: RationalInterval

- Implement interval construction, ordering, arithmetic, containment, intersection, union, reciprocal, midpoint, mediant, and the two power modes.
- Keep interval formatting simple at first: `start:stop`.

Completion: interval arithmetic examples work exactly.

### Phase 4: Fraction and FractionInterval

- Implement unreduced `Fraction`.
- Implement representation equality and rational conversion.
- Implement mediants, Farey helpers, Stern-Brocot helpers.
- Implement `FractionInterval` partition behavior.

Completion: unreduced fraction and tree examples work.

### Phase 5: BaseSystem

- Implement custom digit alphabets, presets, conversion, validation, prefix registry, and base patterns.
- Integrate base-aware integer and rational display.

Completion: binary/hex/custom base examples work.

### Phase 6: Repeating Decimal and Base Expansions

- Implement decimal metadata, period calculation, cycle detection, compact repeated-run notation, and arbitrary-base repeating expansion.
- Add scientific notation.

Completion: repeating decimal and scientific display examples work.

### Phase 7: Continued Fractions and Approximation

- Implement continued fraction conversion, parsing, convergents, approximation errors, and bounded best approximation.

Completion: continued fraction examples work.

### Phase 8: Polish

- Review operator overload choices.
- Add package docs.
- Tighten error behavior.
- Run full test suite.
- Compare representative outputs against JS `packages/core`.

## Design Risks

- Julia's `/` returns floating-point for integers. Use `//` or explicit helpers for exact rational division.
- Julia already defines `Integer`; do not create an exported concrete type named `Integer`.
- Making `RationalInterval <: Number` may create promotion complexity. Start without subtyping `Number`.
- Decimal period calculations can be expensive for huge denominators. Keep limits configurable.
- `random_rational` in JS uses global random state. Julia should accept an RNG argument.
- `BaseSystem.ROMAN` in JS is just an alphabet, not real Roman numeral parsing. Preserve that distinction.

## Success Criteria

The port is successful when:

- It is idiomatic Julia but preserves RatMath's meaningful behavior.
- Exact arithmetic uses `BigInt` and `Rational{BigInt}` internally.
- All examples in `test-design.md` have passing Julia tests.
- The package can be used independently from the JavaScript monorepo.
- Documentation clearly explains where RatMath compatibility differs from standard Julia behavior.
