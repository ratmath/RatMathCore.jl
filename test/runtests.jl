using Test
using RatMathCore

@testset "RatMathCore" begin
    @test rat("5..2/3") == 17//3
    @test rat("-2..1/4") == -9//4
    @test exact_div(5, 2) == 5//2
    @test e_notation(45, -1) == 9//2
    @test bit_length(-5) == 3
    @test double_factorial(6) == 48
    @test to_mixed_string(-7//3) == "-2..1/3"

    @test repeating_decimal(1//2) == "0.5#0"
    @test repeating_decimal(1//3) == "0.#3"
    @test repeating_decimal(1//7) == "0.#142857"
    @test repeating_decimal_with_period(1//7).period == 6
    @test repeating_base(1//3, RatMathCore.BINARY) == "0.#01"

    i = RationalInterval(1, 2)
    j = RationalInterval(3, 4)
    @test i + j == RationalInterval(4, 6)
    @test i - j == RationalInterval(-3, -1)
    @test i * j == RationalInterval(3, 8)
    @test i / j == RationalInterval(1//4, 2//3)
    @test reciprocal(RationalInterval(2, 4)) == RationalInterval(1//4, 1//2)
    @test pow_interval(RationalInterval(-2, 3), 2) == RationalInterval(0, 9)
    @test mpow_interval(RationalInterval(-1, 1), 2) == RationalInterval(-1, 1)
    @test intersection(RationalInterval(1, 3), RationalInterval(2, 4)) == RationalInterval(2, 3)
    @test union(RationalInterval(1, 2), RationalInterval(2, 3)) == RationalInterval(1, 3)
    @test midpoint(RationalInterval(1//3, 2//3)) == 1//2
    @test mediant(RationalInterval(1//3, 1//2)) == 2//5

    f = Fraction(2, 4)
    @test f != Fraction(1, 2)
    @test reduce_fraction(f) == Fraction(1, 2)
    @test rational(f) == 1//2
    @test Fraction(1, 4) + Fraction(2, 4) == Fraction(3, 4)
    @test Fraction(1, 2) / Fraction(3, 4) == Fraction(4, 6)
    @test mediant(Fraction(1, 3), Fraction(1, 2)) == Fraction(2, 5)
    @test is_mediant_triple(Fraction(1, 3), Fraction(2, 5), Fraction(1, 2))
    @test is_farey_triple(Fraction(1, 3), Fraction(2, 5), Fraction(1, 2))
    @test from_stern_brocot_path(stern_brocot_path(Fraction(3, 5))) == Fraction(3, 5)

    fi = FractionInterval(Fraction(1, 3), Fraction(1, 2))
    left, right = mediant_split(fi)
    @test left.high == Fraction(2, 5)
    @test right.low == Fraction(2, 5)
    @test length(partition_with_mediants(fi, 2)) == 4
    @test rational_interval(FractionInterval(Fraction(2, 4), Fraction(3, 6))) == RationalInterval(1//2, 1//2)

    binary = BaseSystem("01", "Binary")
    hex = RatMathCore.HEXADECIMAL
    @test to_decimal(binary, "1010") == 10
    @test from_decimal(binary, 10) == "1010"
    @test to_decimal(hex, "ff") == 255
    @test valid_digit_string(binary, "1010")
    @test !valid_digit_string(binary, "102")
    @test base_system(16) == hex
    @test system_for_prefix("x") == hex

    @test from_continued_fraction([3, 7, 16]) == 355//113
    @test continued_fraction(355//113) == BigInt[3, 7, 16]
    @test continued_fraction_string(3//2) == "1.~2"
    @test from_continued_fraction_string("1.~2") == 3//2
    @test convergents(355//113) == [3//1, 22//7, 355//113]
    @test best_approximation(355//113, 10) == 22//7
end
