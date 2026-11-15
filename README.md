# Julia Port Planning Docs

This folder contains planning material for creating a Julia package that ports the useful parts of `packages/core` without mechanically copying its JavaScript architecture.

[Julia-style documentation site](https://ratmath.github.io/RatMathCore.jl/)

Start here:

- `design.md` - package design and implementation plan.
- `test-design.md` - behavioral test targets and example expectations.
- `AGENTS.md` - coding-agent instructions for using these docs in a new repo.
- `doc-setup/` - Documenter.jl source and documentation environment.
- `docs/` - compiled GitHub Pages-ready documentation after running `doc-setup/make.jl`.
- `samples/` - runnable Julia scripts ported from representative `packages/core/examples` computations.

Run the full sample suite from this folder:

```bash
julia --project=. samples/run_all.jl
```

The intended implementation should use Julia's built-in `BigInt` and `Rational{BigInt}` as the mathematical foundation, then add RatMath-specific interval, unreduced fraction, base-system, and formatting behavior on top.


The main reason for this port is to use this library in a Quarto book which uses js for interactive html version, but for pdf it only compiles julia or python. Went with Julia. 

This repo was almost entirely coded up by the AI Codex 5.5 Medium. 
