using HealthSampleData
using Test

@testset "Utilities" begin
    @testset "progress_callback" begin
        last_pct = Ref(-1)
        @test HealthSampleData.progress_callback(512 * 1024^2, 1024 * 1024^2, last_pct) === nothing
        @test last_pct[] == 50  # 50% progress

        @test HealthSampleData.progress_callback(1024 * 1024^2, 1024 * 1024^2, last_pct) === nothing
        @test last_pct[] == 100  # 100% progress

        @test HealthSampleData.progress_callback(512 * 1024^2, 0, last_pct) === nothing  # Unknown total size
    end
end

@testset "HuggingFaceDatasets - Test dataset" begin
    @test isa(HealthSampleData.Test, Function)
    @test hasmethod(HealthSampleData.Test, Tuple{}) 

    @test isa(HealthSampleData.download_hf_dataset, Function)

    @test_throws ErrorException HealthSampleData.download_hf_dataset("NonExistentDataset12345")
end
