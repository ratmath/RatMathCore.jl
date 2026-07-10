#!/usr/bin/env julia

"""
Compute ``cuberoot(64531)`` by exact-rational Newton iteration and certify
every iterate with the Kantorovich radius used by RatMath's JS root oracle.

The computation itself never rounds: each `x` and its Newton correction are
`Rational{BigInt}` values. `BigFloat` is used only to display those exact
values and the requested error bound in a compact decimal form.
"""

using Printf
using RatMathCore

const TARGET = big(64_531)
const TOLERANCE = rat(1, big(10)^50)

# f(x) = x^3 - TARGET, f'(x) = 3x^2, and f''(x) = 6x.
f(x) = x^3 - TARGET
fprime(x) = 3 * x^2

"""Render an exact number for readable output without changing the proof."""
function decimal(x; digits::Integer=62)
    setprecision(BigFloat, 320) do
        @sprintf("%.*e", digits, BigFloat(x))
    end
end

function main()
    # The positive root lies in [40, 41], because 40^3 < TARGET < 41^3.
    # We use the larger domain [39, 43] for the Kantorovich hypotheses.
    # On this domain |f''(x)| <= 258 and |f'(x)| >= 4563.
    domain = RationalInterval(39, 43)
    max_second_derivative = rat(258)
    min_first_derivative = rat(4_563)
    gamma = max_second_derivative / (2 * min_first_derivative)

    println("Newton--Kantorovich certificate for cbrt(64531)")
    println("f(x) = x^3 - 64531; positive root alpha is in [40, 41].")
    println("Kantorovich domain: ", domain)
    println("On that domain: |f''(x)| <= 258 and |f'(x)| >= 4563.")
    println("gamma = max|f''| / (2 min|f'|) = ", gamma)
    println("Target certified error: 1e-50")
    println()

    x = rat(41)
    iteration = 0

    while true
        residual = f(x)
        derivative = fprime(x)
        beta = abs(residual / derivative)
        kantorovich_h = beta * gamma
        kantorovich_error = 2 * beta
        enclosure = RationalInterval(x - kantorovich_error, x + kantorovich_error)

        kantorovich_h <= 1//4 || error("Kantorovich condition failed at iteration $iteration")
        contains(domain, enclosure) || error("Kantorovich enclosure left the certified domain")

        println("step ", iteration)
        println("  x_", iteration, "                 = ", decimal(x))
        println("  Newton correction beta = ", decimal(beta))
        println("  Kantorovich h          = ", decimal(kantorovich_h))
        println("  Kantorovich error      <= ", decimal(kantorovich_error))
        println("  certified enclosure     = [", decimal(enclosure.low), ", ", decimal(enclosure.high), "]")

        if kantorovich_error <= TOLERANCE
            println()
            println("Certified: |alpha - x_", iteration, "| <= 1e-50.")
            println("The final enclosure has radius less than 1e-50 around x_", iteration, ".")
            return nothing
        end

        x -= residual / derivative
        iteration += 1
        println()
    end
end

main()
