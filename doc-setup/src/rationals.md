# Exact Rationals

Julia already has an excellent exact rational type: `Rational{T}`. RatMathCore.jl uses
`Rational{BigInt}` as its reduced rational representation.

Use [`rat`](@ref) for RatMath-style construction.

```@example rationals
using RatMathCore

rat(6, 8)
```

```@example rationals
rat("1.25")
```

```@example rationals
rat("-2..1/4")
```

## Exact Division

Julia's `/` returns floating-point results for integers. RatMath-style exact division is available
through [`exact_div`](@ref).

```@example rationals
exact_div(6, 3)
```

```@example rationals
exact_div(5, 2)
```

## Mixed Numbers

RatMath mixed numbers use `whole..numerator/denominator`.

```@example rationals
to_mixed_string(17//3)
```

## Repeating Decimals

RatMathCore.jl uses `#` to mark the repeating part:

- `#0` means a terminating decimal.
- `#digits` means `digits` repeat forever.

```@example rationals
repeating_decimal(1//2)
```

```@example rationals
repeating_decimal(1//3)
```

```@example rationals
repeating_decimal_with_period(1//7)
```

## Scientific Notation

Scientific notation remains exact in the sense that it is derived from exact rational metadata.

```@example rationals
scientific_notation(1//7; show_period_info=true)
```

```@example rationals
scientific_notation(1//28; show_period_info=true)
```
