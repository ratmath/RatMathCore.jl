#!/usr/bin/env julia

using RatMathCore

function section(title)
    println()
    println("=== ", title, " ===")
end

function describe_interval(label, interval)
    println(label, " = ", interval)
    println("  midpoint: ", midpoint(interval))
    println("  mediant: ", mediant(interval))
    println("  shortest decimal inside: ", shortest_decimal(interval))
    println("  compacted decimal: ", compacted_decimal_interval(interval))
    println("  relative decimal: ", relative_decimal_interval(interval))
end

function main()
    section("Measurements as exact intervals")
    length_measurement = RationalInterval(99//10, 101//10)
    width_measurement = RationalInterval(49//10, 51//10)
    describe_interval("length", length_measurement)
    describe_interval("width", width_measurement)

    section("Interval arithmetic")
    area = length_measurement * width_measurement
    perimeter = 2 * (length_measurement + width_measurement)
    describe_interval("area", area)
    describe_interval("perimeter", perimeter)

    section("Set-style operations")
    expected = RationalInterval(1//3, 1//2)
    observed = RationalInterval(2//5, 3//5)
    println("expected = ", expected)
    println("observed = ", observed)
    println("overlaps(expected, observed) = ", overlaps(expected, observed))
    println("intersection(expected, observed) = ", intersection(expected, observed))
    println("union(expected, observed) = ", union(expected, observed))
    println("5//12 in expected = ", 5//12 in expected)

    section("Powers and reciprocal")
    centered = RationalInterval(-1//3, 2//3)
    positive = RationalInterval(3//4, 5//4)
    println("centered = ", centered)
    println("pow_interval(centered, 2) = ", pow_interval(centered, 2))
    println("mpow_interval(centered, 2) = ", mpow_interval(centered, 2))
    println("reciprocal(positive) = ", reciprocal(positive))
end

main()
