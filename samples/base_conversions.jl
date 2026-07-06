#!/usr/bin/env julia

using RatMathCore

function section(title)
    println()
    println("=== ", title, " ===")
end

function main()
    binary = RatMathCore.BINARY
    octal = RatMathCore.OCTAL
    hexadecimal = RatMathCore.HEXADECIMAL
    duodecimal = RatMathCore.DUODECIMAL

    section("Integer base conversions")
    value = 3735928559
    println("decimal = ", value)
    println("binary = ", from_decimal(binary, value))
    println("octal = ", from_decimal(octal, value))
    println("hexadecimal = ", from_decimal(hexadecimal, value))
    println("back from hex = ", to_decimal(hexadecimal, "deadbeef"))

    section("Rational base strings")
    println("1//3 in base 10 = ", repeating_decimal(1//3))
    println("1//3 in base 2 = ", repeating_base(1//3, binary))
    println("1//5 in base 2 = ", repeating_base(1//5, binary))
    println("1//7 in base 12 = ", repeating_base(1//7, duodecimal))
    println("22//7 as fraction in hex digits = ", to_base(22//7, hexadecimal))

    section("Custom digit systems")
    dna = BaseSystem(["A", "C", "G", "T"], "DNA Base 4")
    println("from_decimal(dna, 27) = ", from_decimal(dna, 27))
    println("to_decimal(dna, \"CGT\") = ", to_decimal(dna, "CGT"))
    println("valid_digit_string(dna, \"ACGT\") = ", valid_digit_string(dna, "ACGT"))

    letters = create_base_pattern(:uppercase_only, 16; name="Upper Hex")
    println("from_decimal(letters, 255) = ", from_decimal(letters, 255))
end

main()
