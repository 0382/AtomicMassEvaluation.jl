using AME
using Test
using Measurements

@testset "AME.jl" begin
    O16 = get(AME2020, "O16")
    @test getZ(O16) == 8
    @test getN(O16) == 8
    @test getA(O16) == 16
    @test element(O16) == "O"
    @test name(O16) == "O16"
    @test decaymode(O16) == ""
    @test mass(O16) ≈ measurement(-4.73700217, 3.0e-7)
    @test binding_energy(O16) ≈ measurement(127.6193152, 3.2e-6)
    @test beta_decay_energy(O16) ≈ measurement(-15.412184, 0.0053642)
    @test atomic_mass(O16) ≈ measurement(15.99491461926 ± 3.2e-10)
end
