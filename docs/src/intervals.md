# Rational Intervals

[`RationalInterval`](@ref) represents a closed interval with exact rational endpoints.

The constructor preserves the endpoint order as `start` and `stop`, while mathematical operations
use ordered bounds `low` and `high`.

```@example intervals
using RatMathCore

i = RationalInterval(2, 1)
(i.start, i.stop, i.low, i.high)
```

## Arithmetic

```@example intervals
a = RationalInterval(1, 2)
b = RationalInterval(3, 4)

a + b
```

```@example intervals
a - b
```

```@example intervals
a * b
```

```@example intervals
a / b
```

## Powers

RatMathCore.jl separates pointwise interval powers from repeated interval multiplication.

[`pow_interval`](@ref) encloses ``x^n`` for all ``x`` in the interval.

```@example intervals
pow_interval(RationalInterval(-2, 3), 2)
```

[`mpow_interval`](@ref) multiplies the interval by itself repeatedly:

```@example intervals
mpow_interval(RationalInterval(-1, 1), 2)
```

## Set-Like Operations

```@example intervals
intersection(RationalInterval(1, 3), RationalInterval(2, 4))
```

```@example intervals
union(RationalInterval(1, 2), RationalInterval(2, 3))
```

```@example intervals
overlaps(RationalInterval(1, 2), RationalInterval(3, 4))
```

## Helpers

```@example intervals
midpoint(RationalInterval(1//3, 2//3))
```

```@example intervals
mediant(RationalInterval(1//3, 1//2))
```

```@example intervals
repeating_decimal(RationalInterval(1//3, 1//2))
```

## Decimal Interval Displays

Some RatMath displays compress intervals by sharing a decimal prefix or by showing offsets.

```@example intervals
compacted_decimal_interval(RationalInterval(12356//10000, 12367//10000))
```

```@example intervals
relative_mid_decimal_interval(RationalInterval(1224//1000, 1235//1000))
```

```@example intervals
relative_decimal_interval(RationalInterval(1224//1000, 1235//1000))
```
