"""
    laplacian_filter(dem, wavelength, reduction; h=1, cfl=0.2)

Return a floating-point Laplacian-filtered copy of matrix `dem`.

The feature amplitude at `wavelength` is reduced by `reduction`, using
constant grid spacing `h` and explicit diffusion with no-flux boundaries.
"""
function laplacian_filter(dem::AbstractMatrix, wavelength, reduction; h=1, cfl=0.2)
    out = float.(dem) # Promote to floats so integer DEM inputs can diffuse.
    return laplacian_filter!(out, wavelength, reduction; h, cfl)
end

"""
    laplacian_filter!(dem, wavelength, reduction; h=1, cfl=0.2)

Filter matrix `dem` in place with Laplacian smoothing.

The feature amplitude at `wavelength` is reduced by `reduction`, using
constant grid spacing `h` and explicit diffusion with no-flux boundaries.
"""
function laplacian_filter!(dem::AbstractMatrix, wavelength, reduction; h=1, cfl=0.2)
    _check_filter_args(wavelength, reduction, h, cfl)
    eltype(dem) <: AbstractFloat ||
        throw(ArgumentError("dem must have a floating-point element type for in-place filtering"))

    dtmax = cfl * h^2 # Largest stable explicit timestep for an isotropic grid.
    t = -log(reduction) * wavelength^2 / (4π^2) # Diffusion time for target damping.
    n = ceil(Int, t / dtmax) # Round up to keep each explicit step stable.
    n == 0 && return dem

    buf = similar(dem) # Buffer stores the next explicit diffusion state.
    α = (t / n) / h^2 # Use the exact target time split across stable steps.
    for _ in 1:n
        _laplacian_step!(buf, dem, α)
        dem, buf = buf, dem # Swap buffers without reallocating each step.
    end
    isodd(n) && copyto!(buf, dem) # Put the final swapped state back in caller storage.
    return isodd(n) ? buf : dem
end

function _check_filter_args(wavelength, reduction, h, cfl)
    isfinite(wavelength) && wavelength > 0 ||
        throw(ArgumentError("wavelength must be finite and positive"))
    isfinite(reduction) && 0 < reduction <= 1 ||
        throw(ArgumentError("reduction must be finite and satisfy 0 < reduction <= 1"))
    isfinite(h) && h > 0 ||
        throw(ArgumentError("h must be finite and positive"))
    isfinite(cfl) && 0 < cfl <= 0.25 ||
        throw(ArgumentError("cfl must be finite and satisfy 0 < cfl <= 0.25"))
    return nothing
end

function _laplacian_step!(out, dem, α)
    @inbounds for j in axes(dem, 2), i in axes(dem, 1)
        im = max(i - 1, firstindex(dem, 1)) # Clamp row below for no-flux edges.
        ip = min(i + 1, lastindex(dem, 1)) # Clamp row above for no-flux edges.
        jm = max(j - 1, firstindex(dem, 2)) # Clamp column left for no-flux edges.
        jp = min(j + 1, lastindex(dem, 2)) # Clamp column right for no-flux edges.
        z = dem[i, j]
        out[i, j] = z + α * (dem[im, j] + dem[ip, j] + dem[i, jm] + dem[i, jp] - 4z)
    end
    return out
end
