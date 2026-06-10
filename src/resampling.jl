abstract type _ResamplingFilter end

"""
    NoFilter()

Create a resampling filter that leaves the DEM unchanged before interpolation.
"""
struct NoFilter <: _ResamplingFilter end

"""
    Laplacian(wavelength, reduction)

Create a resampling filter that applies [`laplacian_filter`](@ref) before interpolation.
"""
struct Laplacian{T,R} <: _ResamplingFilter
    wavelength::T
    reduction::R
end

"""
    resample(dem, hin, hout, alg::Symbol, filter=NoFilter())

Filter `dem` with `filter`, then resample it from input spacing `hin` to output
spacing `hout`.

The resampling algorithm `alg` must be `:nearest`, `:bilinear`, or `:bicubic`.
The output preserves the point-sampled DEM extent as closely as possible.
"""
function resample(dem::AbstractMatrix, hin, hout, alg::Symbol, filter=NoFilter())
    _check_resample_args(dem, hin, hout)
    fn = _resampler(alg)
    z = _filter_for_resampling(dem, hin, filter) # Filter once so interpolation only samples one array.
    return fn(z, hin, hout)
end

function _check_resample_args(dem, hin, hout)
    all(!iszero, size(dem)) ||
        throw(ArgumentError("dem must have at least one row and one column"))
    isfinite(hin) && hin > 0 ||
        throw(ArgumentError("hin must be finite and positive"))
    isfinite(hout) && hout > 0 ||
        throw(ArgumentError("hout must be finite and positive"))
    return nothing
end

function _resampler(alg)
    alg === :nearest && return _resample_nearest
    alg === :bilinear && return _resample_bilinear
    alg === :bicubic && return _resample_bicubic
    throw(ArgumentError("alg must be :nearest, :bilinear, or :bicubic"))
end

_filter_for_resampling(dem, hin, ::NoFilter) = dem

function _filter_for_resampling(dem, hin, filter::Laplacian)
    return laplacian_filter(dem, filter.wavelength, filter.reduction; h=hin)
end

function _filter_for_resampling(dem, hin, filter)
    throw(ArgumentError("filter must be NoFilter() or Laplacian(wavelength, reduction)"))
end

_out_size(dem, hin, hout) = map(n -> round(Int, (n - 1) * hin / hout) + 1, size(dem))

_coord(k, lo, hin, hout) = lo + (k - 1) * hout / hin

function _resample_nearest(dem, hin, hout)
    m, n = _out_size(dem, hin, hout)
    out = similar(dem, m, n) # Preserve element type because nearest copies samples exactly.
    ilo, ihi = firstindex(dem, 1), lastindex(dem, 1)
    jlo, jhi = firstindex(dem, 2), lastindex(dem, 2)
    @inbounds for j in 1:n, i in 1:m
        x = _coord(i, ilo, hin, hout)
        y = _coord(j, jlo, hin, hout)
        ii = clamp(floor(Int, x + 0.5), ilo, ihi) # Half-grid ties move to the next sample.
        jj = clamp(floor(Int, y + 0.5), jlo, jhi)
        out[i, j] = dem[ii, jj]
    end
    return out
end

function _resample_bilinear(dem, hin, hout)
    m, n = _out_size(dem, hin, hout)
    T = promote_type(float(eltype(dem)), typeof(hout / hin))
    out = Matrix{T}(undef, m, n)
    @inbounds for j in 1:n, i in 1:m
        x = _coord(i, firstindex(dem, 1), hin, hout)
        y = _coord(j, firstindex(dem, 2), hin, hout)
        out[i, j] = _bilinear_at(dem, x, y)
    end
    return out
end

function _bilinear_at(dem, x, y)
    i0, j0 = floor(Int, x), floor(Int, y)
    u, v = x - i0, y - j0 # Fractions inside the surrounding input cell.
    i1 = clamp(i0, firstindex(dem, 1), lastindex(dem, 1))
    i2 = clamp(i0 + 1, firstindex(dem, 1), lastindex(dem, 1))
    j1 = clamp(j0, firstindex(dem, 2), lastindex(dem, 2))
    j2 = clamp(j0 + 1, firstindex(dem, 2), lastindex(dem, 2))
    z11 = dem[i1, j1]
    z21 = dem[i2, j1]
    z12 = dem[i1, j2]
    z22 = dem[i2, j2]
    return (1 - u) * (1 - v) * z11 + u * (1 - v) * z21 + (1 - u) * v * z12 + u * v * z22
end

function _resample_bicubic(dem, hin, hout)
    m, n = _out_size(dem, hin, hout)
    T = promote_type(float(eltype(dem)), typeof(hout / hin))
    out = Matrix{T}(undef, m, n)
    @inbounds for j in 1:n, i in 1:m
        x = _coord(i, firstindex(dem, 1), hin, hout)
        y = _coord(j, firstindex(dem, 2), hin, hout)
        out[i, j] = _bicubic_at(dem, x, y)
    end
    return out
end

function _bicubic_at(dem, x, y)
    i0, j0 = floor(Int, x), floor(Int, y)
    u, v = x - i0, y - j0
    rows = ntuple(4) do a
        ii = clamp(i0 + a - 2, firstindex(dem, 1), lastindex(dem, 1))
        p = ntuple(4) do b
            jj = clamp(j0 + b - 2, firstindex(dem, 2), lastindex(dem, 2))
            dem[ii, jj]
        end
        _catmull_rom(p[1], p[2], p[3], p[4], v) # Interpolate columns before rows.
    end
    return _catmull_rom(rows[1], rows[2], rows[3], rows[4], u)
end

function _catmull_rom(p0, p1, p2, p3, t)
    t2 = t * t
    t3 = t2 * t
    return 0.5 * (2p1 + (-p0 + p2) * t + (2p0 - 5p1 + 4p2 - p3) * t2 + (-p0 + 3p1 - 3p2 + p3) * t3)
end
