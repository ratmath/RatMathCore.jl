#!/usr/bin/env julia

using RatMathCore

function section(title)
    println()
    println("=== ", title, " ===")
end

function main()
    section("Exact rational arithmetic")
    a = rat("1/3")
    b = rat("1/6")
    println("a = ", a)
    println("b = ", b)
    println("a + b = ", a + b)
    println("a - b = ", a - b)
    println("a * b = ", a * b)
    println("a / b = ", a / b)

    section("Mixed numbers and powers")
    mixed_value = mixed(2, 3, 4)
    println("mixed(2, 3, 4) = ", mixed_value)
    println("to_mixed_string(11//4) = ", to_mixed_string(mixed_value))
    println("(3//2)^5 = ", pow_exact(3//2, 5))
    println("reciprocal(7//11) = ", reciprocal(7//11))

    section("Formatting")
    one_seventh = rat("1/7")
    println("to_decimal(1//7; maxdigits=18) = ", to_decimal(one_seventh; maxdigits=18))
    println("repeating_decimal(1//7) = ", repeating_decimal(one_seventh))
    println("scientific_notation(1//7) = ", scientific_notation(one_seventh; show_period_info=true))
    println("bit_length(2^100 - 1) = ", bit_length(big(2)^100 - 1))
end

main()
