# Getting started

DemTools.jl provides small, focused tools for working with digital elevation models (DEMs) in Julia.

## Installation

DemTools.jl is available from its GitHub repository. From the Julia package prompt, run:

```julia
pkg> add https://github.com/utkinis/DemTools.jl
```

For local development, activate the package checkout and instantiate the workspace:

```julia
pkg> activate .
pkg> instantiate
```

## Laplacian smoothing tutorial

The example below builds a synthetic DEM with long hills and short-wavelength roughness, then removes part of that roughness with [`laplacian_filter`](@ref).

```@example getting-started
using CairoMakie
using DemTools

h = 20.0
x = range(0, 2000; step=h)
y = range(0, 2000; step=h)

dem = [120sin(2π * xi / 1600) + 70cos(2π * yj / 1100) + 8sin(2π * (xi + yj) / 180) for xi in x, yj in y] # Synthetic terrain mixes long hills and short roughness.
flt = laplacian_filter(dem, 180, 0.2; h)
res = dem .- flt # Residual shows terrain removed by the filter.

(minimum(dem), maximum(dem), minimum(flt), maximum(flt), maximum(abs, res))
```

The original DEM contains broad hills plus short-wavelength terrain roughness.

```@example getting-started
fig = Figure(; size=(500, 400))
ax = Axis(fig[1, 1]; title="Original DEM", aspect=DataAspect(), xlabel="x (m)", ylabel="y (m)")
hm = heatmap!(ax, x, y, dem; colormap=:terrain)
Colorbar(fig[1, 2], hm; label="Elevation (m)")
fig
```

The filtered DEM keeps the long terrain signal while damping the chosen short wavelength.

```@example getting-started
fig = Figure(; size=(500, 400))
ax = Axis(fig[1, 1]; title="Filtered DEM", aspect=DataAspect(), xlabel="x (m)", ylabel="y (m)")
hm = heatmap!(ax, x, y, flt; colormap=:terrain)
Colorbar(fig[1, 2], hm; label="Elevation (m)")
fig
```

The `wavelength` argument sets the feature scale to attenuate. The `reduction` argument sets the target amplitude left at that wavelength, so `0.2` keeps about 20% of the selected short-scale signal.

Use [`laplacian_filter`](@ref) when you want a filtered copy and [`laplacian_filter!`](@ref) when it is safe to modify a floating-point DEM in place.
