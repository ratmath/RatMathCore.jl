# Base Systems

[`BaseSystem`](@ref) represents a positional numeral system with a custom digit alphabet.

```@example bases
using RatMathCore

binary = BaseSystem("01", "Binary")
to_decimal(binary, "1010")
```

```@example bases
from_decimal(binary, 10)
```

## Standard Bases

[`base_system`](@ref) constructs alphanumeric bases from 2 through 62.

```@example bases
hex = base_system(16)
from_decimal(hex, 255)
```

## Validation

```@example bases
valid_digit_string(binary, "1010")
```

```@example bases
valid_digit_string(binary, "102")
```

## Repeating Expansions in Other Bases

```@example bases
repeating_base(1//3, binary)
```

```@example bases
repeating_base(1//7, base_system(10))
```

## Prefix Registry

The package includes a small prefix registry modeled on RatMath's JavaScript package.

```@example bases
system_for_prefix("x")
```

