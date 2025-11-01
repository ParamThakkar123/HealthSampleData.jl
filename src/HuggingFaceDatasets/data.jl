using HealthSampleData

"""
    register_huggingface_dataset(name::String, repo::String, filename::String)

Registers a dataset from HuggingFace as a DataDep and returns the local path.
"""
function register_huggingface_dataset(name::String, repo::String, filename::String)
    localpath = HealthSampleData._huggingface_dataset_register(name, repo, filename)

    register(DataDep(
        name,
        "Dataset from Hugging Face repository $(repo).",
        "https://huggingface.co/datasets/$(repo)/resolve/main/$(filename)"; 
        fetch_method = p -> localpath
    ))

    return localpath
end

export register_huggingface_dataset