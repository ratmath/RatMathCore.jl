push!(LOAD_PATH, joinpath(@__DIR__, ".."))

using Documenter
using RatMathCore

makedocs(
    sitename = "RatMathCore.jl",
    modules = [RatMathCore],
    build = joinpath(@__DIR__, "..", "docs"),
    format = Documenter.HTML(
        prettyurls = false,
        canonical = nothing,
        edit_link = nothing,
        repolink = nothing,
        assets = String[],
    ),
    pages = [
        "Home" => "index.md",
        "Getting Started" => "getting-started.md",
        "Exact Rationals" => "rationals.md",
        "Intervals" => "intervals.md",
        "Fractions" => "fractions.md",
        "Base Systems" => "bases.md",
        "Continued Fractions" => "continued-fractions.md",
        "Examples" => "examples.md",
        "API Reference" => "api.md",
    ],
    remotes = nothing,
    warnonly = [:missing_docs, :cross_references],
)
