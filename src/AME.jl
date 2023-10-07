module AME

using Measurements

include("constants.jl")
include("Isotope.jl")
const AME2020 = Ref{Vector{Isotope}}()
include("util.jl")

export AME2020,
    Isotope, getZ, getN, getA,
    element, name, decaymode,
    mass, binding_energy, beta_decay_energy, atomic_mass

# Write your package code here.

function __init__()
    current_dir = dirname(@__FILE__)
    global AME2020[] = load_ame2020(current_dir * "/../data/ame2020_mass.txt")
    nothing
end

end
