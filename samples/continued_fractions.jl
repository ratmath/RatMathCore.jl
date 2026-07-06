#!/usr/bin/env julia

using RatMathCore

function section(title)
    println()
    println("=== ", title, " ===")
end

function main()
    section("Finite continued fractions")
    value = 355//113
    terms = continued_fraction(value)
    println("value = ", value)
    println("continued_fraction(value) = ", terms)
    println("continued_fraction_string(value) = ", continued_fraction_string(value))
    println("from_continued_fraction(terms) = ", from_continued_fraction(terms))
    println("from_continued_fraction_string(\"3.~7~16\") = ", from_continued_fraction_string("3.~7~16"))

    section("Convergents")
    target = 103993//33102
    println("target = ", target)
    for (i, c) in enumerate(convergents(target))
        println("convergent ", i - 1, ": ", c, "  error=", approximation_error(c, target))
    end

    section("Best bounded approximations")
    for max_denominator in (5, 10, 50, 100, 1000)
        println("max denominator ", max_denominator, ": ", best_approximation(target, max_denominator))
    end
end

main()
