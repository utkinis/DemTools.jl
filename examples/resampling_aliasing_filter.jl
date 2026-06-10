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
Colorbar(fig[1, end+1]; colormap=:terrain, colorrange=zlim, label="Elevation (m)")
fig
