using AtomicMassEvaluation
using Test
using Measurements

@testset "Isotope" begin
    Ne20 = Isotope("Ne20")
    @test getZ(Ne20) == 10
    @test getN(Ne20) == 10
    @test getA(Ne20) == 20
    @test element(Ne20) == "Ne"
    @test name(Ne20) == "Ne20"
    @test Isotope(Ne20) == Isotope(10, 10)
end

@testset "AME2020" begin
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
