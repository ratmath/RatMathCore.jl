# Unreduced Fractions

[`Fraction`](@ref) preserves numerator and denominator exactly as entered.

This is different from Julia's `Rational`, which always reduces.

```@example fractions
using RatMathCore

Fraction(2, 4) == Fraction(1, 2)
```

```@example fractions
rational(Fraction(2, 4))
```

## Arithmetic

Addition and subtraction intentionally require equal denominators. This preserves the RatMath
JavaScript behavior.

```@example fractions
Fraction(1, 4) + Fraction(2, 4)
```

```@example fractions
Fraction(1, 2) / Fraction(3, 4)
```

```@example fractions
reduce_fraction(Fraction(4, 6))
```

## Mediant

The mediant of ``a/b`` and ``c/d`` is:

```math
\frac{a+c}{b+d}
```

```@example fractions
mediant(Fraction(1, 3), Fraction(1, 2))
```

## Stern-Brocot Paths

```@example fractions
path = stern_brocot_path(Fraction(3, 5))
```

```@example fractions
from_stern_brocot_path(path)
```

## Fraction Intervals

[`FractionInterval`](@ref) preserves unreduced fraction endpoints.

```@example fractions
fi = FractionInterval(Fraction(1, 3), Fraction(1, 2))
mediant_split(fi)
```

```@example fractions
partition_with_mediants(fi, 2)
```

