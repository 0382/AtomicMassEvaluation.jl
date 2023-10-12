# AtomicMassEvaluation

[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](LICENSE)
[![Build Status](https://github.com/0382/AtomicMassEvaluation.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/0382/AtomicMassEvaluation.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/0382/AtomicMassEvaluation.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/0382/AtomicMassEvaluation.jl)

Some data set from Atomic Mass Data Center.

### Usage
```julia-repl
julia> using AtomicMassEvaluation

julia> He4 = get(AME2020, "He4")
Isotope(He4, 2.42491587 ± 1.5e-7, 28.2956624 ± 8.0e-7, -22.9 ± 0.21, 4.00260325413 ± 1.6e-10)

julia> binding_energy(He4)
28.2956624 ± 8.0e-7
```

### Reference

- [Nuclear Data Services](https://www-nds.iaea.org/amdc/).
- AME2020: [Chinese Phys. C 45 030002 (2021)](https://iopscience.iop.org/article/10.1088/1674-1137/abddb0), and [Chinese Phys. C 45 030003 (2021)](https://iopscience.iop.org/article/10.1088/1674-1137/abddaf).