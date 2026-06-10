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
Colorbar(fig[1, end+1]; colormap=:terrain, colorrange=zlim, label="Elevation (m)")
fig
