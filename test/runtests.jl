using DemTools
using Test

roughness(z) = sum(abs2, diff(z; dims=1)) + sum(abs2, diff(z; dims=2))

@testset "laplacian filtering" begin
    dem = [sin(i / 4) + cos(j / 5) for i in 1:20, j in 1:18]
    src = copy(dem)

    out = laplacian_filter(dem, 8, 0.5)
    @test out !== dem
    @test dem == src

    ret = laplacian_filter!(dem, 8, 0.5)
    @test ret === dem
    @test dem ≈ out

    flat = fill(10.0, 8, 9)
    @test laplacian_filter(flat, 5, 0.2) == flat

    ints = [1 2; 3 4]
    @test eltype(laplacian_filter(ints, 5, 0.5)) <: AbstractFloat
    @test_throws ArgumentError laplacian_filter!(ints, 5, 0.5)

    spike = zeros(3, 3)
    spike[2, 2] = 1
    λ, r = 4, 0.95
    α = (-log(r) * λ^2 / (4π^2)) # One scaled step because α < default cfl.
    @test laplacian_filter(spike, λ, r)[2, 2] ≈ 1 - 4α

    x = range(0, 2π; length=50)
    noisy = [sin(xi) + cos(yj) + 0.2sin(15xi + 9yj) for xi in x, yj in x]
    smooth = laplacian_filter(noisy, 4, 0.1)
    @test roughness(smooth) < roughness(noisy)

    @test_throws ArgumentError laplacian_filter(src, 0, 0.5)
    @test_throws ArgumentError laplacian_filter(src, 8, 0)
    @test_throws ArgumentError laplacian_filter(src, 8, 1.1)
    @test_throws ArgumentError laplacian_filter(src, 8, 0.5; h=0)
    @test_throws ArgumentError laplacian_filter(src, 8, 0.5; cfl=0)
    @test_throws ArgumentError laplacian_filter(src, 8, 0.5; cfl=0.3)
end

@testset "DEM resampling" begin
    dem = [1.0 2.0 3.0; 4.0 5.0 6.0; 7.0 8.0 9.0]

    @test NoFilter() isa NoFilter
    @test Laplacian(4, 0.5) isa Laplacian
    @test size(resample(zeros(3, 5), 2, 1, :nearest)) == (5, 9)
    @test size(resample(zeros(5, 5), 1, 2, :nearest)) == (3, 3)

    nearest = resample(dem, 1, 2, :nearest)
    @test nearest == [1.0 3.0; 7.0 9.0]

    ramp = [2i + 3j for i in 1:3, j in 1:4]
    bilinear = resample(ramp, 1, 0.5, :bilinear)
    expected = [2 * (1 + (i - 1) * 0.5) + 3 * (1 + (j - 1) * 0.5) for i in 1:5, j in 1:7]
    @test bilinear ≈ expected

    flat = fill(4.2, 4, 4)
    bicubic = resample(flat, 1, 0.5, :bicubic)
    @test bicubic ≈ fill(4.2, 7, 7)
    @test resample(dem, 1, 0.5, :bicubic)[1:2:end, 1:2:end] ≈ dem

    src = copy(dem)
    copy_resampled = resample(dem, 1, 1, :nearest, NoFilter())
    @test copy_resampled == dem
    @test copy_resampled !== dem
    @test dem == src

    x = range(0, 2π; length=50)
    noisy = [sin(xi) + cos(yj) + 0.2sin(15xi + 9yj) for xi in x, yj in x]
    smooth = resample(noisy, 1, 1, :bilinear, Laplacian(4, 0.1))
    plain = resample(noisy, 1, 1, :bilinear, NoFilter())
    @test roughness(smooth) < roughness(plain)

    @test_throws ArgumentError resample(dem, 0, 1, :nearest)
    @test_throws ArgumentError resample(dem, 1, 0, :nearest)
    @test_throws ArgumentError resample(zeros(0, 2), 1, 1, :nearest)
    @test_throws ArgumentError resample(dem, 1, 1, :lanczos)
    @test_throws ArgumentError resample(dem, 1, 1, :nearest, :badfilter)
end
