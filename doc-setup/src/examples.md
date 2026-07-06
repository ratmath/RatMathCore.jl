# Examples

For larger runnable scripts, see the package's `samples/` directory. These
port representative JavaScript computations from `packages/core/examples` and
can be run with:

```bash
julia --project=. samples/run_all.jl
```

## Exact Computation Without Floating Point

```@example examples
using RatMathCore

x = rat("1/3")
y = rat("1/6")
x + y
```

```@example examples
repeating_decimal(x + y)
```

## Interval Uncertainty

Suppose a value is known to be between ``1/3`` and ``1/2``.

```@example examples
uncertain = RationalInterval(1//3, 1//2)
2 * uncertain + RationalInterval(1, 1)
```

## Decimal Periods

```@example examples
[(n, repeating_decimal_with_period(1//n).period) for n in 2:10]
```

## Custom Digits

```@example examples
balancedish = BaseSystem(["0", "a", "b", "c"], "Toy Base 4")
from_decimal(balancedish, 27)
```

## Mediant Refinement

```@example examples
left = Fraction(1, 3)
right = Fraction(1, 2)
m = mediant(left, right)
(left, m, right)
```

## Continued-Fraction Approximation

```@example examples
target = 355//113
best_approximation(target, 10)
```
