# Continued Fractions

RatMathCore.jl can convert exact rationals to and from continued fractions.

```@example cf
using RatMathCore

continued_fraction(355//113)
```

```@example cf
from_continued_fraction([3, 7, 16])
```

## String Form

RatMath continued-fraction strings use `.~` followed by `~`-separated terms.

```@example cf
continued_fraction_string(355//113)
```

```@example cf
from_continued_fraction_string("3.~7~16")
```

## Convergents

```@example cf
convergents(355//113)
```

```@example cf
best_approximation(355//113, 10)
```

