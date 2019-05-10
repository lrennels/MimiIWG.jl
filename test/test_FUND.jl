
@testset "FUND" begin 

    # include("../src/MimiIWG2016.jl")

    @testset "API" begin

        m = get_model(FUND, scenario_names[1])
        run(m)

        md = get_marginaldamages(FUND, scenario_names[1])

        scc = get_scc(FUND, scenario_names[1])

        tmp_dir = joinpath(@__DIR__, "tmp")
        run_scc_mcs(FUND, trials=2, output_dir = tmp_dir, domestic=true)
        rm(tmp_dir, recursive=true)
    end

end