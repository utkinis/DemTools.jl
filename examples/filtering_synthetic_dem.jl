using CairoMakie
using DemTools

h = 20.0
x = range(0, 2000; step=h)
y = range(0, 2000; step=h)

dem = [120sin(2π * xi / 1600) + 70cos(2π * yj / 1100) + 8sin(2π * (xi + yj) / 180) for xi in x, yj in y] # Synthetic terrain mixes long hills and short roughness.
flt = laplacian_filter(dem, 180, 0.2; h)
res = dem .- flt # Residual shows terrain removed by the filter.

fig = Figure(; size=(450, 1000))
for (k, (ttl, z)) in enumerate((("Original DEM", dem), ("Filtered DEM", flt), ("Residual", res)))
    ax = Axis(fig[k, 1]; title=ttl, aspect=DataAspect(), xlabel="x (m)", ylabel="y (m)")
    hm = heatmap!(ax, x, y, z; colormap=:terrain)
    Colorbar(fig[k, 2], hm; label="Elevation (m)")
end

display(fig)
