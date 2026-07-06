# Getting Started

## Load the Package

From the package root:

```bash
cd /Users/jostylr/ai-repos/ratmath/julia-port
julia --project=.
```

Then:

```@example getting-started
using RatMathCore
```

## Run the Tests

In this repository, direct test execution avoids Julia registry access:

```bash
cd /Users/jostylr/ai-repos/ratmath/julia-port
mkdir -p .julia_depot
JULIA_DEPOT_PATH=/Users/jostylr/ai-repos/ratmath/julia-port/.julia_depot: julia --project=. -e 'include("test/runtests.jl")'
rm -rf .julia_depot
```

If your Julia installation already has registry access configured, this may also work:

```bash
julia --project=. -e 'using Pkg; Pkg.test()'
```

## Build the Documentation

Documenter.jl is installed in the docs environment:

```bash
cd /Users/jostylr/ai-repos/ratmath/julia-port
julia --project=docs docs/make.jl
```

The generated site is written to:

```text
docs/build/
```

## First Examples

```@example getting-started
rat("3/4") + rat("1/6")
```

```@example getting-started
to_mixed_string(-7//3)
```

```@example getting-started
repeating_decimal(1//6)
```

