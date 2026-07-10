# RatMathCore Samples

These scripts port representative computations from `packages/core/examples` to
the Julia package API.

Run one sample from the `julia-port` package root:

```bash
julia --project=. samples/basic_usage.jl
```

Run every sample:

```bash
julia --project=. samples/run_all.jl
```

The samples are written as small scripts rather than tests. They show expected
usage patterns and print exact rational, interval, base-conversion, continued
fraction, Stern-Brocot, and decimal-formatting results.

`newton_kantorovich_cube_root.jl` additionally demonstrates a certified
numerical computation. It finds `cuberoot(64531)` using exact-rational Newton
iteration and prints the Kantorovich error bound after every step, stopping only
once the bound is at most `1e-50`.
