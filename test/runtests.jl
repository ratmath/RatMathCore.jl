using Test
using RatMathCore

@testset "RatMathCore" begin
    @test rat("5..2/3") == 17//3
    @test rat("-2..1/4") == -9//4
    @test rat("1.25") == 5//4
    @test rat("-0.125") == -1//8
    @test_throws ArgumentError rat("3//4")
    @test_throws ArgumentError rat("1.2.3")
    @test exact_div(5, 2) == 5//2
    @test exact_div(6, 3) == 2
    @test_throws DivideError exact_div(1, 0)
    @test e_notation(45, -1) == 9//2
    @test e_notation(1//3, 3) == 1000//3
    @test bit_length(-5) == 3
    @test double_factorial(6) == 48
    @test_throws DomainError double_factorial(-1)
    @test to_mixed_string(-7//3) == "-2..1/3"
    @test to_mixed_string(1//2) == "1/2"
    @test reciprocal(2//3) == 3//2
    @test_throws DomainError reciprocal(0//1)
    @test pow_exact(2//3, -2) == 9//4
    @test_throws DomainError pow_exact(0//1, 0)

    @test repeating_decimal(1//2) == "0.5#0"
    @test repeating_decimal(1//3) == "0.#3"
    @test repeating_decimal(1//7) == "0.#142857"
    @test repeating_decimal(-1//6) == "-0.1#6"
    @test repeating_decimal_with_period(1//7).period == 6
    @test repeating_decimal_with_period(1//4).period == 0
    @test repeating_base(1//3, RatMathCore.BINARY) == "0.#01"
    @test period_modulo(1//7, RatMathCore.DECIMAL) == 6

    i = RationalInterval(1, 2)
    j = RationalInterval(3, 4)
    @test i + j == RationalInterval(4, 6)
    @test i - j == RationalInterval(-3, -1)
    @test i * j == RationalInterval(3, 8)
    @test i / j == RationalInterval(1//4, 2//3)
    @test reciprocal(RationalInterval(2, 4)) == RationalInterval(1//4, 1//2)
    @test_throws DomainError reciprocal(RationalInterval(-1, 1))
    @test pow_interval(RationalInterval(-2, 3), 2) == RationalInterval(0, 9)
    @test pow_interval(RationalInterval(-2, 3), 3) == RationalInterval(-8, 27)
    @test pow_interval(RationalInterval(2, 3), -1) == RationalInterval(1//3, 1//2)
    @test_throws DomainError pow_interval(RationalInterval(-1, 1), -1)
    @test mpow_interval(RationalInterval(-1, 1), 2) == RationalInterval(-1, 1)
    @test_throws DomainError mpow_interval(RationalInterval(1, 2), 0)
    @test overlaps(RationalInterval(1, 3), RationalInterval(2, 4))
    @test !overlaps(RationalInterval(1, 2), RationalInterval(3, 4))
    @test intersection(RationalInterval(1, 3), RationalInterval(2, 4)) == RationalInterval(2, 3)
    @test intersection(RationalInterval(1, 2), RationalInterval(3, 4)) === nothing
    @test union(RationalInterval(1, 2), RationalInterval(2, 3)) == RationalInterval(1, 3)
    @test union(RationalInterval(1, 2), RationalInterval(3, 4)) === nothing
    @test midpoint(RationalInterval(1//3, 2//3)) == 1//2
    @test mediant(RationalInterval(1//3, 1//2)) == 2//5
    @test compacted_decimal_interval(RationalInterval(12356//10000, 12367//10000)) == "1.23[56,67]"
    @test relative_mid_decimal_interval(RationalInterval(1224//1000, 1235//1000)) == "1.2295[+-0.0055]"
    @test occursin(r"^1\.23\[", relative_decimal_interval(RationalInterval(1224//1000, 1235//1000)))

    f = Fraction(2, 4)
    @test f != Fraction(1, 2)
    @test Fraction("3/4") == Fraction(3, 4)
    @test Fraction(1, 3) < Fraction(1, 2)
    @test_throws ArgumentError Fraction(1, 0)
    @test Fraction(1, 0; allow_infinite=true).infinite
    @test reduce_fraction(f) == Fraction(1, 2)
    @test rational(f) == 1//2
    @test Fraction(1, 4) + Fraction(2, 4) == Fraction(3, 4)
    @test_throws ArgumentError Fraction(1, 4) + Fraction(1, 2)
    @test Fraction(1, 2) / Fraction(3, 4) == Fraction(4, 6)
    @test pow_exact(Fraction(2, 3), -1) == Fraction(3, 2)
    @test scale(Fraction(1, 2), 3) == Fraction(3, 6)
    @test e_notation(Fraction(3, 8), -1) == Fraction(3, 80)
    @test mediant(Fraction(1, 3), Fraction(1, 2)) == Fraction(2, 5)
    @test is_mediant_triple(Fraction(1, 3), Fraction(2, 5), Fraction(1, 2))
    @test is_farey_triple(Fraction(1, 3), Fraction(2, 5), Fraction(1, 2))
    @test farey_parents(Fraction(0, 1)).left == Fraction(-1, 0; allow_infinite=true)
    @test_throws ArgumentError farey_parents(Fraction(1, 0; allow_infinite=true))
    @test stern_brocot_path(Fraction(0, 1)) == Char[]
    @test from_stern_brocot_path(stern_brocot_path(Fraction(3, 5))) == Fraction(3, 5)
    @test stern_brocot_depth(Fraction(0, 1)) == 0

    fi = FractionInterval(Fraction(1, 3), Fraction(1, 2))
    left, right = mediant_split(fi)
    @test left.high == Fraction(2, 5)
    @test right.low == Fraction(2, 5)
    @test partition_with_mediants(fi, 0) == [fi]
    @test length(partition_with_mediants(fi, 2)) == 4
    @test_throws ArgumentError partition_with_mediants(fi, -1)
    @test length(partition_with(fi, (lo, hi) -> [mediant(lo, hi)])) == 2
    @test_throws ArgumentError partition_with(fi, (lo, hi) -> [1//2])
    @test rational_interval(FractionInterval(Fraction(2, 4), Fraction(3, 6))) == RationalInterval(1//2, 1//2)
    @test fraction_interval(RationalInterval(1//3, 1//2)) == fi

    binary = BaseSystem("01", "Binary")
    hex = RatMathCore.HEXADECIMAL
    @test_throws ArgumentError BaseSystem("00", "Bad")
    @test_throws ArgumentError BaseSystem("0+", "Bad")
    @test to_decimal(binary, "1010") == 10
    @test from_decimal(binary, 10) == "1010"
    @test from_decimal(binary, -10) == "-1010"
    @test to_decimal(hex, "ff") == 255
    @test_throws ArgumentError to_decimal(binary, "102")
    @test valid_digit_string(binary, "1010")
    @test !valid_digit_string(binary, "102")
    @test base_system(16) == hex
    @test_throws ArgumentError base_system(63)
    @test create_base_pattern(:digits_only, 10).base == 10
    @test_throws ArgumentError create_base_pattern(:digits_only, 11)
    @test system_for_prefix("x") == hex
    custom = BaseSystem("abc", "Custom")
    register_prefix!("z", custom)
    @test system_for_prefix("z") == custom
    unregister_prefix!("z")
    @test system_for_prefix("z") === nothing

    @test from_continued_fraction([3, 7, 16]) == 355//113
    @test continued_fraction(355//113) == BigInt[3, 7, 16]
    @test continued_fraction_string(3//2) == "1.~2"
    @test from_continued_fraction_string("1.~2") == 3//2
    @test convergents(355//113) == [3//1, 22//7, 355//113]
    @test get_convergent(355//113, 1) == 22//7
    @test_throws BoundsError get_convergent(355//113, 5)
    @test approximation_error(22//7, 355//113) == abs(22//7 - 355//113)
    @test best_approximation(355//113, 10) == 22//7
end
