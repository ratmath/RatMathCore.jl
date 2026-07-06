module RatMathCore

import Base: +, -, *, /, ==, <, <=, show, string, hash, isless, union

export rat, mixed, exact_div, pow_exact, reciprocal, e_notation, bit_length, double_factorial
export to_mixed_string, to_decimal
export RationalInterval, point_interval, parse_interval, contains_zero, overlaps
export intersection, union, midpoint, mediant, pow_interval, mpow_interval
export shortest_decimal, random_rational
export compacted_decimal_interval, relative_mid_decimal_interval, relative_decimal_interval
export Fraction, FractionInterval, reduce_fraction, rational, scale
export farey_parents, mediant_partner, is_mediant_triple, is_farey_triple
export stern_brocot_path, from_stern_brocot_path, stern_brocot_parent
export stern_brocot_children, stern_brocot_depth, stern_brocot_ancestors
export stern_brocot_string
export mediant_split, partition_with_mediants, partition_with, rational_interval, fraction_interval
export BaseSystem, base_system, create_base_pattern, to_decimal, from_decimal
export valid_digit_string, with_case_sensitivity, register_prefix!, unregister_prefix!
export system_for_prefix, prefix_for_system, get_char
export repeating_decimal, repeating_decimal_with_period, repeating_base, repeating_base_with_period
export period_modulo, scientific_notation
export continued_fraction, from_continued_fraction, continued_fraction_string
export from_continued_fraction_string, convergents, convergents_from_cf
export get_convergent, approximation_error, best_approximation

include("bases.jl")
include("compatibility.jl")
include("decimal_format.jl")
include("continued_fractions.jl")
include("fractions.jl")
include("intervals.jl")
include("docstrings.jl")

end
