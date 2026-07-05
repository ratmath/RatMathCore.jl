# RatMath Core Julia Port Test Design

This document lists behavioral targets for the Julia port. It is not runnable test code. Each example should become one or more tests in the new Julia repository.

Expected values are written in a Julia-friendly style, but exact function names may change slightly during implementation. Keep the behavior stable even if names are adjusted.

## Test Organization

Recommended test files:

- `rational_tests.jl`
- `interval_tests.jl`
- `fraction_tests.jl`
- `fraction_interval_tests.jl`
- `base_tests.jl`
- `formatting_tests.jl`
- `continued_fraction_tests.jl`
- `compatibility_tests.jl`

Use exact equality for numeric results. For display tests, compare exact strings.

## Basic Exact Helpers

### BigInt Helpers

Targets:

- `bigint(0)` equals `BigInt(0)`.
- `bigint("123456789012345678901234567890")` preserves all digits.
- `bit_length(0)` returns `0`.
- `bit_length(1)` returns `1`.
- `bit_length(5)` returns `3`.
- `bit_length(-5)` returns `3`.
- `double_factorial(0)` returns `1`.
- `double_factorial(1)` returns `1`.
- `double_factorial(5)` returns `15`.
- `double_factorial(6)` returns `48`.
- `double_factorial(-1)` throws.

### Exact Division Compatibility

Targets:

- `exact_div(6, 3)` returns integer `2`.
- `exact_div(5, 2)` returns rational `5//2`.
- `exact_div(-5, 2)` returns rational `-5//2`.
- `exact_div(1, 0)` throws.

### E Notation

Targets:

- `e_notation(5, 2)` returns `500`.
- `e_notation(123, 0)` returns `123`.
- `e_notation(45, -1)` returns `9//2`.
- `e_notation(1//4, -1)` returns `1//40`.
- `e_notation(1//3, 3)` returns `1000//3`.

## Rational Construction and Arithmetic

### Construction

Targets:

- `rat(3)` returns `3//1`.
- `rat(3, 4)` returns `3//4`.
- `rat(6, 8)` returns `3//4`.
- `rat(1, -2)` returns `-1//2`.
- `rat(0, 5)` returns `0//1`.
- `rat(1, 0)` throws.

### String Parsing

Targets:

- `rat("5")` returns `5//1`.
- `rat("-5")` returns `-5//1`.
- `rat("3/4")` returns `3//4`.
- `rat("-6/8")` returns `-3//4`.
- `rat("1.25")` returns `5//4`.
- `rat("-0.125")` returns `-1//8`.
- `rat("5..2/3")` returns `17//3`.
- `rat("-2..1/4")` returns `-9//4`.
- Invalid strings like `"3//4"`, `"abc"`, `"1.2.3"`, and `"1..2"` throw.

### Arithmetic

Targets:

- `1//2 + 1//3` returns `5//6`.
- `1//2 - 1//3` returns `1//6`.
- `1//2 * 1//3` returns `1//6`.
- `(1//2) / (1//3)` returns `3//2`.
- `-(1//2)` returns `-1//2`.
- `reciprocal(2//3)` returns `3//2`.
- `reciprocal(0//1)` throws.
- `pow_exact(2//3, 2)` returns `4//9`.
- `pow_exact(2//3, -2)` returns `9//4`.
- `pow_exact(0//1, 0)` throws for RatMath compatibility.
- `pow_exact(0//1, -1)` throws.

### Mixed Strings

Targets:

- `to_mixed_string(5//1)` returns `"5"`.
- `to_mixed_string(7//3)` returns `"2..1/3"`.
- `to_mixed_string(-7//3)` returns `"-2..1/3"`.
- `to_mixed_string(1//2)` returns `"1/2"`.
- `to_mixed_string(-1//2)` returns `"-1/2"`.
- `to_mixed_string(0//1)` returns `"0"`.

## Rational Decimal Formatting

### Plain Decimal Approximation

Targets:

- `to_decimal(0//1)` returns `"0"`.
- `to_decimal(1//1)` returns `"1"`.
- `to_decimal(1//2)` returns `"0.5"`.
- `to_decimal(1//4)` returns `"0.25"`.
- `to_decimal(1//3)` returns `"0.33333333333333333333"` with the default 20 digit limit.
- `to_decimal(-1//8)` returns `"-0.125"`.

### Repeating Decimal

Targets:

- `repeating_decimal(0//1)` returns `"0"`.
- `repeating_decimal(1//1)` returns `"1"`.
- `repeating_decimal(1//2)` returns `"0.5#0"`.
- `repeating_decimal(1//4)` returns `"0.25#0"`.
- `repeating_decimal(1//3)` returns `"0.#3"`.
- `repeating_decimal(1//6)` returns `"0.1#6"`.
- `repeating_decimal(1//7)` returns `"0.#142857"`.
- `repeating_decimal(-1//6)` returns `"-0.1#6"`.
- `repeating_decimal_with_period(1//7).period` returns `6`.
- `repeating_decimal_with_period(1//4).period` returns `0`.

### Compact Repeat Notation

Targets:

- Runs shorter than or equal to six characters are not compacted.
- Runs longer than six characters are compacted as `"{digit~count}"`.
- A repeating sequence with seven zeros should include `"{0~7}"`.
- Compact notation can be disabled and then all digits are literal.

### Scientific Notation

Targets:

- `scientific_notation(0//1)` returns `"0"`.
- `scientific_notation(123//1)` returns `"1.23E2"` or the chosen documented trimmed equivalent.
- `scientific_notation(1//1000)` returns `"1E-3"` or the chosen documented equivalent.
- `scientific_notation(1//3)` includes repeating marker `"#3"`.
- Negative values preserve the leading minus sign.
- `show_period_info=true` includes period metadata for repeating decimals.

## RationalInterval

### Construction

Targets:

- `RationalInterval(1, 2).low == 1//1`.
- `RationalInterval(1, 2).high == 2//1`.
- `RationalInterval(2, 1).low == 1//1`.
- `RationalInterval(2, 1).high == 2//1`.
- `RationalInterval(2, 1).start == 2//1`.
- `RationalInterval(2, 1).stop == 1//1`.
- `point_interval(3//4)` has low and high equal to `3//4`.
- `parse_interval("1/3:2/3")` returns endpoints `1//3` and `2//3`.

### Arithmetic

Targets:

- `[1,2] + [3,4]` returns `[4,6]`.
- `[1,2] - [3,4]` returns `[-3,-1]`.
- `[1,2] * [3,4]` returns `[3,8]`.
- `[-1,2] * [3,4]` returns `[-4,8]`.
- `[-2,-1] * [-4,-3]` returns `[3,8]`.
- `[1,2] / [3,4]` returns `[1//4, 2//3]`.
- Division by an interval containing zero throws.
- `recip([2,4])` returns `[1//4, 1//2]`.
- `recip([-4,-2])` returns `[-1//2, -1//4]`.
- `recip([-1,1])` throws.
- `-[1,2]` returns `[-2,-1]`.

### Powers

Targets:

- `pow_interval([2,3], 2)` returns `[4,9]`.
- `pow_interval([-3,-2], 2)` returns `[4,9]`.
- `pow_interval([-2,3], 2)` returns `[0,9]`.
- `pow_interval([-2,3], 3)` returns `[-8,27]`.
- `pow_interval([2,3], -1)` returns `[1//3, 1//2]`.
- `pow_interval([-1,1], -1)` throws.
- `pow_interval([0,0], 0)` throws.
- `mpow_interval([-1,1], 2)` returns `[-1,1]`, demonstrating dependency-preserving interval multiplication rather than pointwise squaring.

### Set-Like Operations

Targets:

- `[1,3]` overlaps `[2,4]`.
- `[1,2]` overlaps `[2,3]`.
- `[1,2]` does not overlap `[3,4]`.
- `[1,4]` contains `[2,3]`.
- `[1,4]` contains value `3`.
- `[1,4]` does not contain value `5`.
- `intersection([1,3], [2,4])` returns `[2,3]`.
- `intersection([1,2], [3,4])` returns `nothing`.
- `union([1,3], [2,4])` returns `[1,4]`.
- `union([1,2], [2,3])` returns `[1,3]`.
- `union([1,2], [3,4])` returns `nothing`.

### Interval Helpers

Targets:

- `midpoint([1,3])` returns `2`.
- `midpoint([1//3, 2//3])` returns `1//2`.
- `mediant([1//3, 1//2])` returns `2//5`.
- `shortest_decimal([1224//1000, 1235//1000])` returns a rational inside the interval with a power-of-10 denominator, such as `123//100`.
- `random_rational([0,1], max_denominator=10)` always returns a reduced rational inside `[0,1]`.

### Interval Formatting

Targets:

- `string(RationalInterval(1//3, 2//3))` returns `"1/3:2/3"`.
- `to_mixed_string(RationalInterval(7//3, 10//3))` returns `"2..1/3:3..1/3"`.
- `repeating_decimal(RationalInterval(1//3, 1//2))` returns `"0.#3:0.5#0"`.
- Relative and compact interval decimal notation should match documented examples once implemented.

## Fraction

### Construction and Representation

Targets:

- `Fraction(1, 2).num == 1`.
- `Fraction(1, 2).den == 2`.
- `Fraction("3/4") == Fraction(3, 4)`.
- `Fraction(5) == Fraction(5, 1)`.
- `Fraction(2, 4) != Fraction(1, 2)`.
- `Fraction(1, 0)` throws by default.
- `Fraction(1, 0; allow_infinite=true)` succeeds and is infinite.
- `Fraction(2, 0; allow_infinite=true)` throws.

### Arithmetic

Targets:

- `Fraction(1,4) + Fraction(2,4)` returns `Fraction(3,4)`.
- `Fraction(1,4) + Fraction(1,2)` throws because denominators differ.
- `Fraction(3,4) - Fraction(1,4)` returns `Fraction(2,4)`.
- `Fraction(1,2) * Fraction(3,4)` returns `Fraction(3,8)`.
- `Fraction(1,2) / Fraction(3,4)` returns `Fraction(4,6)`.
- Dividing by a zero-numerator fraction throws.
- `pow_fraction(Fraction(2,3), 2)` returns `Fraction(4,9)`.
- `pow_fraction(Fraction(2,3), -1)` returns `Fraction(3,2)`.
- `scale(Fraction(1,2), 3)` returns `Fraction(3,6)`.
- `reduce_fraction(Fraction(4,6))` returns `Fraction(2,3)`.
- `rational(Fraction(4,6))` returns `2//3`.
- `e_notation(Fraction(5,4), 2)` returns `Fraction(500,4)`.
- `e_notation(Fraction(3,8), -1)` returns `Fraction(3,80)`.

### Comparisons

Targets:

- `Fraction(1,3) < Fraction(1,2)`.
- `Fraction(2,4)` and `Fraction(1,2)` compare as equal numerically if a numeric comparison helper is exposed.
- Representation equality remains false for `Fraction(2,4) == Fraction(1,2)`.

### Mediant and Farey

Targets:

- `mediant(Fraction(1,3), Fraction(1,2))` returns `Fraction(2,5)`.
- `is_mediant_triple(Fraction(1,3), Fraction(2,5), Fraction(1,2))` returns `true`.
- `is_farey_triple(Fraction(1,3), Fraction(2,5), Fraction(1,2))` returns `true`.
- `farey_parents(Fraction(0,1))` returns left `Fraction(-1,0; allow_infinite=true)` and right `Fraction(1,0; allow_infinite=true)`.
- `farey_parents` of an infinite fraction throws.

### Stern-Brocot

Targets:

- `stern_brocot_path(Fraction(0,1))` returns an empty vector.
- `from_stern_brocot_path([])` returns `Fraction(0,1)`.
- For several reduced finite fractions, `from_stern_brocot_path(stern_brocot_path(f)) == reduce_fraction(f)`.
- Infinite fractions have no path, parent, or children.
- `stern_brocot_depth(Fraction(0,1))` returns `0`.
- `stern_brocot_depth` for an infinite fraction returns `Inf` or the documented equivalent.

## FractionInterval

### Construction

Targets:

- `FractionInterval(Fraction(1,3), Fraction(1,2)).low == Fraction(1,3)`.
- Reversed endpoints are ordered by numeric value.
- Non-`Fraction` endpoints throw.

### Partitioning

Targets:

- `mediant_split(FractionInterval(1/3, 1/2))` splits at `2/5`.
- `partition_with_mediants(interval, 0)` returns the original interval.
- `partition_with_mediants(interval, 1)` returns two intervals.
- `partition_with_mediants(interval, 2)` returns four intervals.
- Negative partition depth throws.
- `partition_with` accepts a function returning internal `Fraction` points.
- `partition_with` throws if callback returns non-fractions.
- `partition_with` throws if points fall outside the interval.

### Conversion

Targets:

- `rational_interval(FractionInterval(Fraction(2,4), Fraction(3,6)))` reduces endpoints to `1//2:1//2`.
- `fraction_interval(RationalInterval(1//3, 1//2))` returns `Fraction(1,3):Fraction(1,2)`.
- `e_notation(FractionInterval(Fraction(1,2), Fraction(3,4)), 2)` returns endpoints `Fraction(100,2)` and `Fraction(300,4)`.

## BaseSystem

### Construction

Targets:

- `BaseSystem("01", "Binary").base == 2`.
- `BaseSystem(["0", "1", "2"], "Ternary").base == 3`.
- Duplicate characters throw.
- Fewer than two characters throw.
- Reserved symbols throw if used as digits.
- Non-string or invalid character inputs throw.

### Digit Conversion

Targets:

- Binary `to_decimal("1010")` returns `10`.
- Binary `from_decimal(10)` returns `"1010"`.
- Hex `to_decimal("ff")` returns `255`.
- Hex `from_decimal(255)` returns `"ff"`.
- Decimal `from_decimal(-42)` returns `"-42"`.
- Invalid digits throw for `to_decimal`.
- `valid_digit_string(binary, "1010")` returns `true`.
- `valid_digit_string(binary, "102")` returns `false`.

### Presets and Patterns

Targets:

- `base_system(2)` equals the binary preset.
- `base_system(16)` equals lowercase hexadecimal.
- `base_system(62)` includes digits, lowercase letters, and uppercase letters.
- `base_system(63)` throws for default construction unless custom characters are provided.
- `create_base_pattern(:digits_only, 10)` works.
- `create_base_pattern(:digits_only, 11)` throws.
- `create_base_pattern(:letters_only, 52)` works.
- `create_base_pattern(:uppercase_only, 26)` works.
- Unknown pattern throws.

### Prefix Registry

Targets:

- Prefix `"b"` maps to binary by default.
- Prefix `"x"` maps to hexadecimal by default.
- Prefix `"D"` returns `nothing` or the documented reserved result.
- Registering prefix `"z"` for a custom base makes lookup return that base.
- Unregistering prefix `"z"` removes it.
- Prefixes must be single letters.

### Base-Aware Rational Output

Targets:

- Integer `10` in base 2 displays as `"1010"`.
- Rational `10//3` in base 2 as a simple fraction displays as `"1010/11"` if using direct numerator/denominator base conversion.
- `repeating_base(1//3, decimal)` returns `"0.#3"`.
- `repeating_base(1//3, binary)` returns `"0.#01"`.
- `repeating_base(1//7, decimal)` returns `"0.#142857"`.
- Terminating fractions include `#0`.

## Continued Fractions

### Construction from Coefficients

Targets:

- `from_continued_fraction([3])` returns `3//1`.
- `from_continued_fraction([1, 2])` returns `3//2`.
- `from_continued_fraction([0, 2])` returns `1//2`.
- Empty coefficient arrays throw.
- Non-positive terms after the first throw.

### Conversion to Coefficients

Targets:

- `continued_fraction(3//1)` returns `[3]`.
- `continued_fraction(3//2)` returns `[1, 2]`.
- `continued_fraction(7//3)` returns `[2, 3]`.
- `continued_fraction(355//113)` returns `[3, 7, 16]` or the canonical equivalent chosen by the package.
- Negative rationals use floor-style first term and roundtrip through `from_continued_fraction`.
- No result should end with a final `1` unless documented as canonical.

### String Form

Targets:

- `continued_fraction_string(3//1)` returns `"3.~0"`.
- `continued_fraction_string(3//2)` returns `"1.~2"`.
- `from_continued_fraction_string("1.~2")` returns `3//2`.
- `from_continued_fraction_string("5.~0")` returns `5//1`.
- Strings with missing integer part, double tildes, trailing tildes, or non-positive terms throw.

### Convergents and Approximation

Targets:

- `convergents(355//113)` returns `[3//1, 22//7, 355//113]` if using canonical `[3,7,16]`.
- `get_convergent(355//113, 0)` returns `3//1`.
- Out-of-range convergent indexes throw.
- `approximation_error(22//7, 355//113)` returns `abs(22//7 - 355//113)`.
- `best_approximation(355//113, 10)` returns `22//7`.
- `best_approximation(355//113, 1000)` returns `355//113`.

## Error and Edge Case Targets

General targets:

- Invalid constructors throw `ArgumentError` where possible.
- Division by zero and reciprocal of zero throw.
- Intervals containing zero cannot be divisors.
- Negative powers of zero throw.
- `0^0` in RatMath compatibility helpers throws.
- Very large denominators in period calculations respect configured limits.
- Random functions accept an RNG or seedable equivalent so tests can be deterministic when needed.

## Cross-Checks Against JavaScript

For early validation, compare these outputs manually against `packages/core`:

- `1/3`, `1/6`, `1/7`, `1/28`, `1/125`, `1/99991` repeating decimal metadata.
- `[1/3, 1/2]` interval arithmetic and display.
- `Fraction(2,4)` representation equality and rational conversion.
- Base 2, base 16, and custom base rational expansions.
- Continued fraction roundtrips for `355/113`, `22/7`, `-7/3`, and `0`.
