"""
    Base.get(data::Ref{Vector{Isotope}}, isotope::Isotope)
get an `IsotopeData` from the dataset by isotope
"""
Base.get(data::Ref{Vector{IsotopeData}}, isotope::Isotope) = begin
    for item in data[]
        if item.isotope == isotope
            return item
        end
    end
    return nothing
end

"""
    Base.get(data::Ref{Vector{Isotope}}, isoname::AbstractString)
get an `IsotopeData` from the dataset by name
"""
Base.get(data::Ref{Vector{IsotopeData}}, isoname::AbstractString) = get(data, Isotope(isoname))
