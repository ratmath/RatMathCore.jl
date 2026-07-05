# Julia Port Planning Docs

This folder contains planning material for creating a Julia package that ports the useful parts of `packages/core` without mechanically copying its JavaScript architecture.

Start here:

- `design.md` - package design and implementation plan.
- `test-design.md` - behavioral test targets and example expectations.
- `AGENTS.md` - coding-agent instructions for using these docs in a new repo.

The intended implementation should use Julia's built-in `BigInt` and `Rational{BigInt}` as the mathematical foundation, then add RatMath-specific interval, unreduced fraction, base-system, and formatting behavior on top.
