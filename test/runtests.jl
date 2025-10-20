using Test
using Pkg
using HealthSampleData

@testset "huggingface helper tests" begin
    @test_throws ArgumentError HealthSampleData.load("nonexistent_dataset")

    if get(ENV, "HF_INTEGRATION", "0") == "1"
        @info "Running HF integration test (will download from Hugging Face)"
        path = nothing
        try
            path = HealthSampleData.load("synthea_1M_3YR")
            @test ispath(path)
        finally
            @info "HF integration test result path: $path"
        end
    else
        @info "Skipping HF integration test (set HF_INTEGRATION=1 to enable)"
    end
end