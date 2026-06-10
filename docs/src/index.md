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

## Tutorial examples

These examples show the three main workflows in DemTools.jl: filtering a noisy DEM, resampling a coarse DEM, and filtering before coarsening to avoid aliasing.

### Filtering

Use [`laplacian_filter`](@ref) to damp short-wavelength terrain while keeping broader structure. Increasing the damping makes the high-frequency roughness fade more strongly.

```@example getting-started-filtering
using CairoMakie
using DemTools

h = 20.0
x = range(0, 2000; step=h)
y = range(0, 2000; step=h)

dem = [100sin(2π * xi / 1500) +
       50cos(2π * yj / 1000) +
       25sin(2π * (xi - yj) / 500) +
       20cos(2π * (xi + 0.5yj) / 150) for xi in x, yj in y]
cases = (("Original", dem),
         ("Mild", laplacian_filter(dem, 160.0, 0.5; h)),
         ("Strong", laplacian_filter(dem, 160.0, 0.03; h)))

fig = Figure(; size=(800, 260))
zlim = extrema(dem)
for (k, (label, z)) in enumerate(cases)
    ax = Axis(fig[1, k]; title=label, aspect=DataAspect())
    heatmap!(ax, x, y, z; colormap=:terrain, colorrange=zlim)
    hidedecorations!(ax)
end
Colorbar(fig[1, end + 1]; colormap=:terrain, limits=zlim, label="Elevation (m)")
fig
```

### Resampling

Use [`resample`](@ref) to change DEM spacing. This coarse input makes interpolation differences visible: bilinear interpolation creates simpler transitions, while bicubic interpolation is smoother.

```@example getting-started-resampling
using CairoMakie
using DemTools

hin = 200.0
hout = 50.0
x = range(0, 2100; step=hin)
y = range(0, 2100; step=hin)

dem = [130sin(2π * xi / 1800) +
       80cos(2π * yj / 1400) +
       45sin(2π * (xi + 0.4yj) / 900) for xi in x, yj in y]
algs = (:bilinear, :bicubic)

fig = Figure(; size=(800, 260))
zlim = extrema(dem)

ax0 = Axis(fig[1, 1]; title="Input, 120 m", aspect=DataAspect())
heatmap!(ax0, x, y, dem; colormap=:terrain, colorrange=zlim)
hidedecorations!(ax0)

for (r, alg) in enumerate(algs)
    z = resample(dem, hin, hout, alg)
    xo = range(first(x), last(x); length=size(z, 1))
    yo = range(first(y), last(y); length=size(z, 2))
    ax = Axis(fig[1, r + 1]; title=string(alg, ", 20 m"), aspect=DataAspect())
    heatmap!(ax, xo, yo, z; colormap=:terrain, colorrange=zlim)
    hidedecorations!(ax)
end
Colorbar(fig[1, end + 1]; colormap=:terrain, limits=zlim, label="Elevation (m)")
fig
```

### Filtering Before Resampling

When coarsening a DEM, short waves can fold into false broad patterns. Applying [`Laplacian`](@ref) before resampling removes much of that aliasing.

```@example getting-started-aliasing
using CairoMakie
using DemTools

hin = 20.0
hout = 100.0
x = range(0, 2000; step=hin)
y = range(0, 2000; step=hin)

dem = [100sin(2π * xi / 1500) +
       50cos(2π * yj / 1000) +
       25sin(2π * (xi - yj) / 500) +
       20cos(2π * (xi + 0.5yj) / 150) for xi in x, yj in y]
raw = resample(dem, hin, hout, :bicubic, NoFilter())
flt = resample(dem, hin, hout, :bicubic, Laplacian(180.0, 0.03))

fig = Figure(; size=(800, 260))
zlim = extrema(dem)
cases = (("Input, 20 m", dem, x, y),
         ("no filter", raw, range(first(x), last(x); length=size(raw, 1)), range(first(y), last(y); length=size(raw, 2))),
         ("Laplacian filter", flt, range(first(x), last(x); length=size(flt, 1)), range(first(y), last(y); length=size(flt, 2))))

for (r, (label, z, xo, yo)) in enumerate(cases)
    ax = Axis(fig[1, r]; title=label, aspect=DataAspect())
    heatmap!(ax, xo, yo, z; colormap=:terrain, colorrange=zlim)
    hidedecorations!(ax)
end
Colorbar(fig[1, end + 1]; colormap=:terrain, limits=zlim, label="Elevation (m)")
fig
```
