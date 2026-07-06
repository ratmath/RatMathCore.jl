#!/usr/bin/env julia

using RatMathCore

function section(title)
    println()
    println("=== ", title, " ===")
end

function main()
    section("Unreduced fractions")
    raw = Fraction(6, 8)
    println("raw Fraction(6, 8) = ", raw)
    println("reduce_fraction(raw) = ", reduce_fraction(raw))
    println("rational(raw) = ", rational(raw))
    println("scale(Fraction(2, 3), 5) = ", scale(Fraction(2, 3), 5))

    section("Mediants and Farey parents")
    left = Fraction(1, 3)
    right = Fraction(1, 2)
    middle = mediant(left, right)
    println("left = ", left)
    println("right = ", right)
    println("mediant(left, right) = ", middle)
    println("is_mediant_triple(left, middle, right) = ", is_mediant_triple(left, middle, right))
    println("is_farey_triple(left, middle, right) = ", is_farey_triple(left, middle, right))
    println("farey_parents(Fraction(2, 5)) = ", farey_parents(Fraction(2, 5)))

    section("Stern-Brocot paths")
    target = Fraction(5, 7)
    path = stern_brocot_string(target)
    println("target = ", target)
    println("stern_brocot_string(target) = ", path)
    println("from_stern_brocot_path(path) = ", from_stern_brocot_path(path))
    println("stern_brocot_parent(target) = ", stern_brocot_parent(target))
    println("stern_brocot_children(target) = ", stern_brocot_children(target))
    println("stern_brocot_depth(target) = ", stern_brocot_depth(target))
    println("stern_brocot_ancestors(target) = ", stern_brocot_ancestors(target))

    section("Fraction intervals")
    interval = FractionInterval(Fraction(1, 3), Fraction(1, 2))
    println("interval = ", interval)
    println("mediant_split(interval) = ", mediant_split(interval))
    println("rational_interval(interval) = ", rational_interval(interval))
end

main()
