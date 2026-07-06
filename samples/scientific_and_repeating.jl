#!/usr/bin/env julia

using RatMathCore

function section(title)
    println()
    println("=== ", title, " ===")
end

function main()
    values = [1//7, 1//28, 1//81, 22//7, -1//13, 123456789//100000]

    section("Repeating decimals")
    for value in values
        details = repeating_decimal_with_period(value)
        println(value, " -> ", details.decimal, "  period=", details.period)
    end

    section("Scientific notation")
    for value in values
        println(value, " -> ", scientific_notation(value; show_period_info=true))
    end

    section("Period modulo checks")
    for denominator in 2:12
        value = 1//denominator
        println("1//", denominator, ": decimal period ", period_modulo(value, RatMathCore.DECIMAL),
            ", binary period ", period_modulo(value, RatMathCore.BINARY))
    end
end

main()
