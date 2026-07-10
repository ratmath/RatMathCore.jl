#!/usr/bin/env julia

const SAMPLE_FILES = [
    "basic_usage.jl",
    "interval_uncertainty.jl",
    "continued_fractions.jl",
    "base_conversions.jl",
    "fractions_stern_brocot.jl",
    "scientific_and_repeating.jl",
    "newton_kantorovich_cube_root.jl",
]

for file in SAMPLE_FILES
    println()
    println("############################################################")
    println("# samples/", file)
    println("############################################################")
    include(joinpath(@__DIR__, file))
end
