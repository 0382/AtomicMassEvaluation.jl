Base.get(data::Ref{Vector{Isotope}}, isoname::AbstractString) = begin
    for iso in data[]
        if name(iso) == isoname
            return iso
        end
    end
    return nothing
end