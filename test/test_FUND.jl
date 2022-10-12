using DelimitedFiles
using MimiIWG
using Test

validation_dir = joinpath(@__DIR__, "../data/validation/FUND/usg 2013 fund deterministic run results/")
validation_files = readdir(validation_dir)  # separate file for each scenario and gas

_atol = 1e-3

@testset "FUND" begin

    @testset "API" begin

        m = MimiIWG.get_model(FUND, MimiIWG.scenarios[1])
        run(m)

        md1 = MimiIWG.get_marginaldamages(FUND, MimiIWG.scenarios[1], gas=:CO2, year=2020, discount=0.0)
        md2 = MimiIWG.get_marginaldamages(FUND, MimiIWG.scenarios[1], gas=:CO2, year=2020, discount=0.0, regional=true)

        scc1 = MimiIWG.compute_scc(FUND, MimiIWG.scenarios[1], gas=:CO2, year=2020, discount=0.03)
        scc2 = MimiIWG.compute_scc(FUND, MimiIWG.scenarios[1], gas=:CO2, year=2020, discount=0.03, domestic=true)
        @test scc2 < scc1  # test global SCC is larger than domestic SCC

        # Test monte carlo simulation runs without error
        tmp_dir = joinpath(@__DIR__, "tmp")
        MimiIWG.run_scc_mcs(FUND, gas=:CO2, trials=2, output_dir=tmp_dir, domestic=true)
        rm(tmp_dir, recursive=true)
    end

    # Test the deterministic (non Monte Carlo) results from a modal run of FUND against values from the EPA

    # Carbon dioxide
    @testset "Deterministic SC-CO2 validation" begin

        for scen in MimiIWG.scenarios
            @info("Testing FUND SC-CO2 $(MimiIWG.fund_scenario_convert[scen])...")
            file_idx = findfirst(x -> occursin("$(MimiIWG.fund_scenario_convert[scen]) - C", x), validation_files)
            scen_file = validation_files[file_idx]
            scen_validation_values = readdlm(joinpath(validation_dir, scen_file), ',')[3, 2:16]

            idx = 1
            for year in 2010:10:2050, dr in [0.025, 0.03, 0.05]
                mimi_scc = MimiIWG.compute_scc(FUND, scen, gas=:CO2, year=year, discount=dr)
                iwg_scc = scen_validation_values[idx]
                @test mimi_scc ≈ iwg_scc atol = _atol
                idx += 1
            end
        end
    end

    # Methane
    @testset "Deterministic SC-CH4 validation" begin

        for scen in MimiIWG.scenarios
            @info("Testing FUND SC-CH4 $(MimiIWG.fund_scenario_convert[scen])...")
            file_idx = findfirst(x -> occursin("$(MimiIWG.fund_scenario_convert[scen]) - CH4", x), validation_files)
            scen_file = validation_files[file_idx]
            scen_validation_values = readdlm(joinpath(validation_dir, scen_file), ',')[3, 2:16]

            idx = 1
            for year in 2010:10:2050, dr in [0.025, 0.03, 0.05]
                mimi_scc = MimiIWG.compute_scc(FUND, scen, gas=:CH4, year=year, discount=dr)
                iwg_scc = scen_validation_values[idx]
                @test mimi_scc ≈ iwg_scc atol = _atol
                idx += 1
            end
        end
    end

    # Nitrous oxide
    @testset "Deterministic SC-N2O validation" begin

        for scen in MimiIWG.scenarios
            @info("Testing FUND SC-N2O $(MimiIWG.fund_scenario_convert[scen])...")
            file_idx = findfirst(x -> occursin("$(MimiIWG.fund_scenario_convert[scen]) - N2O", x), validation_files)
            scen_file = validation_files[file_idx]
            scen_validation_values = readdlm(joinpath(validation_dir, scen_file), ',')[3, 2:16]

            idx = 1
            for year in 2010:10:2050, dr in [0.025, 0.03, 0.05]
                mimi_scc = MimiIWG.compute_scc(FUND, scen, gas=:N2O, year=year, discount=dr)
                iwg_scc = scen_validation_values[idx]
                @test mimi_scc ≈ iwg_scc atol = 5.0
                idx += 1
            end
        end
    end

end
