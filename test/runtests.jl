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
