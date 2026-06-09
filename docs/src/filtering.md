# DEM filtering

Digital elevation models often contain detail at many scales: broad topographic structure, real small-scale terrain, sampling artefacts, interpolation noise, and sensor noise. Filtering helps separate the terrain scale that matters for an analysis from the shorter wavelengths that can dominate gradients, curvature, flow routing, or visual interpretation.

DEM filtering is needed when roughness at the grid scale makes downstream measurements unstable or hides larger geomorphic patterns. A smoother DEM can make slope fields less noisy, reduce spurious local extrema, and make scale-dependent comparisons more reproducible.

DemTools.jl currently provides Laplacian filtering, which behaves like explicit diffusion on a regular grid. Short wavelengths decay faster than long wavelengths, so choosing a target `wavelength` and `reduction` gives direct control over the scale of terrain that is damped.

```@example filtering
using DemTools

dem = [sin(i / 8) + cos(j / 6) + 0.25sin(3i + 2j) for i in 1:40, j in 1:35] # Smooth hills plus fine ripples.
smooth = laplacian_filter(dem, 8, 0.1)

roughness(z) = sum(abs2, diff(z; dims = 1)) + sum(abs2, diff(z; dims = 2)) # Smaller values mean less grid-scale variation.

roughness(smooth) < roughness(dem)
```

Use the grid spacing keyword `h` when DEM cells are not spaced one unit apart. For in-place filtering, the DEM must already have a floating-point element type because diffusion creates fractional elevation values.
