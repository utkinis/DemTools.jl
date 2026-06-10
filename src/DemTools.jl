module DemTools

export Laplacian, NoFilter, laplacian_filter, laplacian_filter!, resample

include("filtering.jl")
include("resampling.jl")

end # module DemTools
