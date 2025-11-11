# helper: ensure a stable per-user cache for immediate returns (avoids datadep interactive prompts)
function _cache_and_return(localpath::String, name::String, filename::String)
    cache_dir = joinpath(homedir(), ".julia", "HealthSampleData_datasets", name)
    mkpath(cache_dir)
    dest = joinpath(cache_dir, filename)
    cp(localpath, dest; force=true)
    @info "$name dataset cached at $dest"
    return dest
end

function Synthea()
    localpath = HealthSampleData._huggingface_dataset_register("Synthea", "JuliaHealthOrg/JuliaHealthDatasets", "synthea_1M_3YR.duckdb")
    register(DataDep(
        "Synthea",
        "1 million patients each with 3 year retrospective medical histories generated using the Synthea data generator (https://synthea.mitre.org). DuckDB database following the OMOP Common Data Model layout.",
        "https://huggingface.co/datasets/JuliaHealthOrg/JuliaHealthDatasets/blob/main/synthea_1M_3YR.duckdb"; 
        # fetch_method gets called as (remotepath, localdir) by DataDeps
        fetch_method = (remotepath, localdir) -> begin
            mkpath(localdir)
            dest = joinpath(localdir, "synthea_1M_3YR.duckdb")
            cp(localpath, dest; force=true)
            return dest
        end
    ))

    # Do not call datadep"Synthea" directly (avoids interactive prompt when a stale datadep dir exists).
    # Instead, cache the downloaded file in a per-user location and return that path immediately.
    return _cache_and_return(localpath, "Synthea", "synthea_1M_3YR.duckdb")
end


function Test()
    localpath = HealthSampleData._huggingface_dataset_register("Test", "JuliaHealthOrg/JuliaHealthDatasets", "penguins.csv")
    register(DataDep(
        "Test",
        """
        The Palmer Penguins test dataset for HealthSampleData.jl. To cite:

        Horst AM, Hill AP, Gorman KB (2020). palmerpenguins: Palmer
        Archipelago (Antarctica) penguin data. R package version 0.1.0.
        https://allisonhorst.github.io/palmerpenguins/. doi:
        10.5281/zenodo.3960218.

        """,
        "https://huggingface.co/datasets/JuliaHealthOrg/JuliaHealthDatasets/penguins.csv"; 
        fetch_method = (remotepath, localdir) -> begin
            mkpath(localdir)
            dest = joinpath(localdir, "penguins.csv")
            cp(localpath, dest; force=true)
            return dest
        end
    ))

    # Avoid calling datadep"Test" here to prevent DataDeps interactive prompt on stale installs.
    return _cache_and_return(localpath, "Test", "penguins.csv")
end

"""
    register_huggingface_dataset(name::String)

Registers a dataset from HuggingFace as a DataDep and returns the local path.
"""
function download_hf_dataset(name::String)
    if name == "Synthea"
        @info "Downloading Synthea dataset as DataDep..."
        return Synthea()
    elseif name == "Test"
        @info "Downloading Test dataset as DataDep..."
        return Test()
    else
        error("Dataset registration for $name is not implemented.")
    end
end

export download_hf_dataset