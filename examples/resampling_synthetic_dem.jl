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
    ax = Axis(fig[1, r+1]; title=string(alg, ", 20 m"), aspect=DataAspect())
    heatmap!(ax, xo, yo, z; colormap=:terrain, colorrange=zlim)
    hidedecorations!(ax)
end
Colorbar(fig[1, end+1]; colormap=:terrain, colorrange=zlim, label="Elevation (m)")
fig
