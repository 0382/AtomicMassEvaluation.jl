"""
    Isotope
Isotope is a struct that contains the information of an isotope.
The information includes the proton number, neutron number, element symbol, decay mode, mass, binding energy, beta decay energy, and atomic mass.
"""
struct Isotope
    N::Int
    Z::Int
    element::String
    decay_mode::String
    mass::Measurement{Float64}
    binding_energy::Measurement{Float64}
    beta_decay_energy::Union{Measurement{Float64},Missing}
    atomic_mass::Measurement{Float64}
    mass_is_esitimated::Bool
    binding_energy_is_estimated::Bool
    beta_decay_energy_is_estimated::Bool
    atomic_mass_is_estimated::Bool
    function Isotope(N::Int, Z::Int, element::AbstractString, decay_mode::AbstractString, mass::Measurement{Float64}, binding_energy::Measurement{Float64}, beta_decay_energy::Union{Measurement{Float64},Missing}, atomic_mass::Measurement{Float64}, mass_is_esitimated::Bool, binding_energy_is_estimated::Bool, beta_decay_energy_is_estimated::Bool, atomic_mass_is_estimated::Bool)
        return new(N, Z, element, decay_mode, mass, binding_energy, beta_decay_energy, atomic_mass, mass_is_esitimated, binding_energy_is_estimated, beta_decay_energy_is_estimated, atomic_mass_is_estimated)
    end
end

function parse_ame2020_line(line::AbstractString)
    N = parse(Int, line[5:9])
    Z = parse(Int, line[10:14])
    A = parse(Int, line[15:19])
    N + Z == A || error("N + Z != A")
    element = strip(line[21:23])
    decay_mode = strip(line[24:27])

    # parse mass
    tstr = strip(line[29:42])
    mass_is_esitimated = false
    if endswith(tstr, "#")
        tstr = tstr[1:end-1]
        mass_is_esitimated = true
    end
    mass_value = parse(Float64, tstr)
    tstr = strip(line[43:54])
    if mass_is_esitimated
        tstr = tstr[1:end-1]
    end
    mass_uncertainty = parse(Float64, tstr)
    mass = measurement(mass_value / 1000, mass_uncertainty / 1000)

    # parse binding energy
    tstr = strip(line[55:67])
    binding_energy_is_estimated = false
    if endswith(tstr, "#")
        tstr = tstr[1:end-1]
        binding_energy_is_estimated = true
    end
    binding_energy_value = parse(Float64, tstr)
    tstr = strip(line[69:78])
    if binding_energy_is_estimated
        tstr = tstr[1:end-1]
    end
    binding_energy_uncertainty = parse(Float64, tstr)
    binding_energy = measurement(binding_energy_value / 1000, binding_energy_uncertainty / 1000)

    # parse beta decay energy
    tstr = strip(line[82:94])
    beta_decay_energy = missing
    beta_decay_energy_is_estimated = false
    if tstr ≠ "*"
        if endswith(tstr, "#")
            tstr = tstr[1:end-1]
            beta_decay_energy_is_estimated = true
        end
        beta_decay_energy_value = parse(Float64, tstr)
        tstr = strip(line[95:105])
        if beta_decay_energy_is_estimated
            tstr = tstr[1:end-1]
        end
        beta_decay_energy_uncertainty = parse(Float64, tstr)
        beta_decay_energy = measurement(beta_decay_energy_value / 1000, beta_decay_energy_uncertainty / 1000)
    end

    # parse atomic mass
    am_major = parse(Int, line[107:109])
    tstr = strip(line[111:123])
    atomic_mass_is_estimated = false
    if endswith(tstr, "#")
        tstr = tstr[1:end-1]
        atomic_mass_is_estimated = true
    end
    atomic_mass_value = parse(Float64, tstr) / 1000_000 + am_major
    tstr = strip(line[124:end])
    if atomic_mass_is_estimated
        tstr = tstr[1:end-1]
    end
    atomic_mass_uncertainty = parse(Float64, tstr) / 1000_000
    atomic_mass = measurement(atomic_mass_value, atomic_mass_uncertainty)
    return Isotope(N, Z, element, decay_mode, mass, binding_energy, beta_decay_energy, atomic_mass, mass_is_esitimated, binding_energy_is_estimated, beta_decay_energy_is_estimated, atomic_mass_is_estimated)
end

"""
    getZ(iso::Isotope)
get the proton number of the isotope
"""
getZ(iso::Isotope) = iso.Z
"""
    getN(iso::Isotope)
get the neutron number of the isotope
"""
getN(iso::Isotope) = iso.N
"""
    getA(iso::Isotope)
get the mass number of the isotope
"""
getA(iso::Isotope) = iso.N + iso.Z
"""
    element(iso::Isotope)
get the element symbol of the isotope
"""
element(iso::Isotope) = iso.element
"""
    name(iso::Isotope)
get the name of the isotope
"""
name(iso::Isotope) = iso.element * string(getA(iso))
"""
    decaymode(iso::Isotope)
get the decay mode of the isotope
"""
decaymode(iso::Isotope) = iso.decay_mode
"""
    mass(iso::Isotope)
get the mass of the isotope
"""
mass(iso::Isotope) = iso.mass
"""
    average_binding_energy(iso::Isotope)
get the average binding energy of the isotope
"""
average_binding_energy(iso::Isotope) = iso.binding_energy
"""
    binding_energy(iso::Isotope)
get the binding energy of the isotope
"""
binding_energy(iso::Isotope) = iso.binding_energy * getA(iso)
"""
    beta_decay_energy(iso::Isotope)
get the beta decay energy of the isotope
"""
beta_decay_energy(iso::Isotope) = iso.beta_decay_energy
"""
    atomic_mass(iso::Isotope)
get the atomic mass of the isotope
"""
atomic_mass(iso::Isotope) = iso.atomic_mass


Base.show(io::IO, iso::Isotope) = begin
    print(io, "Isotope(")
    print(io, name(iso))
    print(io, ", ")
    print(io, mass(iso))
    print(io, ", ")
    print(io, binding_energy(iso))
    print(io, ", ")
    print(io, beta_decay_energy(iso))
    print(io, ", ")
    print(io, atomic_mass(iso))
    print(io, ")")
end


function load_ame2020(fname::AbstractString)
    ame2020 = Vector{Isotope}()
    fp = open(fname, "r")
    for i = 1:36
        readline(fp)
    end
    for line in eachline(fp)
        iso = parse_ame2020_line(line)
        push!(ame2020, iso)
    end
    close(fp)
    sort!(ame2020, by=x -> (getZ(x), getN(x)))
    return ame2020
end