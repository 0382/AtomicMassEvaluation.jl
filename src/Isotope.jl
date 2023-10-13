"""
    struct Isotope
        Z::Int
        N::Int
    end
Isotope struct, constructors as follows:
```julia
Isotope(iso::Isotope)
Isotope(Z::Integer, N::Integer)
Isotope(name::AbstractString) # parse the name of the isotope, e.g. `Ne20`
```
"""
struct Isotope
    Z::Int
    N::Int
    Isotope(Z::Integer, N::Integer) = begin
        Z >= 0 || error("Z must be non-negative")
        N >= 0 || error("N must be non-negative")
        Z <= 118 || error("Z must be less than or equal to 118")
        new(Z, N)
    end
end

Isotope(iso::Isotope) = iso
Isotope(name::AbstractString) = parse(Isotope, name)

Base.parse(::Type{Isotope}, str::AbstractString)::Isotope = begin
    m = match(r"([A-Z][a-z]*)(\d{1,3})", str)
    m === nothing && error("match error in parsing '$str'")
    name = m.captures[1]
    A = parse(Int, m.captures[2])
    A > 0 || error("$str isotope has a non-positive mass number $A")
    Z = findfirst(x -> x == name, isotope_names)
    Z === nothing && error("no such element '$name'")
    Z = Z - 1
    N = A - Z
    N >= 0 || error("$str isotope has a negative neutron number $N")
    Isotope(Z, N)
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
getA(iso::Isotope) = iso.Z + iso.N

"""
    element(iso::Isotope)
get the element symbol of the isotope
"""
element(iso::Isotope) = isotope_names[iso.Z + 1]

"""
    name(iso::Isotope)
get the name of the isotope
"""
name(iso::Isotope) = element(iso) * string(getA(iso))

Base.show(io::IO, ::MIME"text/plain", iso::Isotope) = print(io, name(iso))

Base.show(io::IO, ::MIME"text/markdown", iso::Isotope) = begin
    ele = element(iso)
    A = getA(iso)
    show(io, "text/markdown", Markdown.parse("``^{$A}\\mathrm{$ele}``"))
end


"""
    IsotopeData
Isotope is a struct that contains the information of an isotope.
The information includes the decay mode, mass, binding energy, beta decay energy, and atomic mass.
"""
struct IsotopeData
    isotope::Isotope
    decay_mode::String
    mass::Measurement{Float64}
    binding_energy::Measurement{Float64}
    beta_decay_energy::Union{Measurement{Float64},Missing}
    atomic_mass::Measurement{Float64}
    mass_is_esitimated::Bool
    binding_energy_is_estimated::Bool
    beta_decay_energy_is_estimated::Bool
    atomic_mass_is_estimated::Bool
    function IsotopeData(iso::Isotope, decay_mode::AbstractString, mass::Measurement{Float64}, binding_energy::Measurement{Float64}, beta_decay_energy::Union{Measurement{Float64},Missing}, atomic_mass::Measurement{Float64}, mass_is_esitimated::Bool, binding_energy_is_estimated::Bool, beta_decay_energy_is_estimated::Bool, atomic_mass_is_estimated::Bool)
        return new(iso, decay_mode, mass, binding_energy, beta_decay_energy, atomic_mass, mass_is_esitimated, binding_energy_is_estimated, beta_decay_energy_is_estimated, atomic_mass_is_estimated)
    end
end

function parse_ame2020_line(line::AbstractString)
    N = parse(Int, line[5:9])
    Z = parse(Int, line[10:14])
    A = parse(Int, line[15:19])
    @assert N + Z == A
    iso = Isotope(Z, N)
    ele = strip(line[21:23])
    @assert ele == element(iso)
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
    return IsotopeData(iso, decay_mode, mass, binding_energy, beta_decay_energy, atomic_mass, mass_is_esitimated, binding_energy_is_estimated, beta_decay_energy_is_estimated, atomic_mass_is_estimated)
end

"""
    getZ(isodata::IsotopeData)
get the proton number of the `IsotopeData`
"""
getZ(isodata::IsotopeData) = getZ(isodata.isotope)
"""
    getN(isodata::IsotopeData)
get the neutron number of the `IsotopeData`
"""
getN(isodata::IsotopeData) = getN(isodata.isotope)
"""
    getA(isodata::IsotopeData)
get the mass number of the `IsotopeData`
"""
getA(isodata::IsotopeData) = getA(isodata.isotope)
"""
    element(isodata::IsotopeData)
get the element symbol of the `IsotopeData`
"""
element(isodata::IsotopeData) = element(isodata.isotope)
"""
    name(isodata::IsotopeData)
get the name of the `IsotopeData`
"""
name(isodata::IsotopeData) = name(isodata.isotope)
"""
    decaymode(isodata::IsotopeData)
get the decay mode of the `IsotopeData`
"""
decaymode(isodata::IsotopeData) = isodata.decay_mode
"""
    mass(isodata::IsotopeData)
get the mass of the `IsotopeData`
"""
mass(isodata::IsotopeData) = isodata.mass
"""
    average_binding_energy(isodata::IsotopeData)
get the average binding energy of the `IsotopeData`
"""
average_binding_energy(isodata::IsotopeData) = isodata.binding_energy
"""
    binding_energy(isodata::IsotopeData)
get the binding energy of the `IsotopeData`
"""
binding_energy(isodata::IsotopeData) = isodata.binding_energy * getA(isodata)
"""
    beta_decay_energy(isodata::IsotopeData)
get the beta decay energy of the `IsotopeData`
"""
beta_decay_energy(isodata::IsotopeData) = isodata.beta_decay_energy
"""
    atomic_mass(isodata::IsotopeData)
get the atomic mass of the `IsotopeData`
"""
atomic_mass(isodata::IsotopeData) = isodata.atomic_mass


Base.show(io::IO, isodata::IsotopeData) = begin
    print(io, "IsotopeData(")
    print(io, name(isodata))
    print(io, ", ")
    print(io, mass(isodata))
    print(io, ", ")
    print(io, binding_energy(isodata))
    print(io, ", ")
    print(io, beta_decay_energy(isodata))
    print(io, ", ")
    print(io, atomic_mass(isodata))
    print(io, ")")
end


function load_ame2020(fname::AbstractString)
    ame2020 = Vector{IsotopeData}()
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