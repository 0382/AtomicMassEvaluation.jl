# Home

Some data set from Atomic Mass Data Center.

### Usage
```@setup example
push!(LOAD_PATH, "../../src") # hide
```

```@example example
using AtomicMassEvaluation
He4 = get(AME2020, "He4")
binding_energy(He4)
```

### Types
```@docs
Isotope
```

### Dateset
```@docs
AME2020
```

### Methods
```@docs
getZ
getN
getA
element
name
decaymode
mass
binding_energy
average_binding_energy
beta_decay_energy
atomic_mass
Base.get(::Ref{Vector{Isotope}}, ::AbstractString)
```

### Reference

- [Nuclear Data Services](https://www-nds.iaea.org/amdc/).
- AME2020: [Chinese Phys. C 45 030002 (2021)](https://iopscience.iop.org/article/10.1088/1674-1137/abddb0), and [Chinese Phys. C 45 030003 (2021)](https://iopscience.iop.org/article/10.1088/1674-1137/abddaf).