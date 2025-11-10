module HealthSampleData

	using DataDeps
	using HuggingFaceHub
	using Logging
	
	include("utilities.jl")
	include("huggingface.jl")
	include("OMOP_Common_Data_Model/data.jl")
	include("HuggingFaceDatasets/data.jl")

end
