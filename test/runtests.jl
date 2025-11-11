using HealthSampleData
using Test

@testset "Utilities" begin
end

@testset "HuggingFaceDatasets - Test dataset" begin
    @test isa(HealthSampleData.Test, Function)
    @test hasmethod(HealthSampleData.Test, Tuple{}) 

    @test isa(HealthSampleData.download_hf_dataset, Function)

    @test_throws ErrorException HealthSampleData.download_hf_dataset("NonExistentDataset12345")
end
