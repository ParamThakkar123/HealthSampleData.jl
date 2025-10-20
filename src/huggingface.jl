const HF = HuggingFaceHub

"""
    _huggingface_dataset_register(name::String, repo::String, filename::String)

Resolve dataset metadata from Hugging Face, download `filename` via HuggingFaceHub,
register a DataDep pointing at the HF URL, and return the local filesystem path
to the downloaded file. Displays download progress when possible.
"""
function _huggingface_dataset_register(name::String, repo::String, filename::String)
    @info "Resolving Huggingface Metadata for $repo"
    dataset = HF.info(HF.Dataset, repo)

    last_pct = Ref(-1)
    progress_fn = function(downloaded::Integer, total::Integer)
        if total > 0
            safe_downloaded = min(downloaded, total)
            pct = clamp(Int(floor(100 * safe_downloaded / total)), 0, 100)
            if pct != last_pct[]
                last_pct[] = pct
                downloaded_mb = round(safe_downloaded / 1024^2; digits=1)
                total_mb = round(total / 1024^2; digits=1)
                @info "Download progress: $pct% ($downloaded_mb MB / $total_mb MB)"
            end
        else
            downloaded_mb = round(downloaded / 1024^2; digits=1)
            @info "Downloaded $downloaded_mb MB"
        end
        return nothing
    end

    @info "Downloading $filename from $repo via HuggingFaceHub..."
    try
        localpath = nothing
        try
            localpath = HF.file_download(dataset, filename; progress = progress_fn)
        catch inner
            if inner isa MethodError
                @warn "HuggingFaceHub.file_download does not support progress callback on this version; falling back to no-progress call."
                localpath = HF.file_download(dataset, filename)
            else
                rethrow(inner)
            end
        end
        @info "Downloaded to $localpath"
    catch e
        msg = string(e)
        if occursin("symlink", msg) || occursin("creating symlinks", msg) || occursin("Administrator", msg) || occursin("operation not permitted", msg)
            @warn "Symlink creation failed (likely Windows privilege). Falling back to direct HTTP download: $e"
            url = "https://huggingface.co/datasets/$(repo)/resolve/main/$(filename)"
            tmpdir = mktempdir()
            dest = joinpath(tmpdir, filename)
            @info "Downloading $url -> $dest (no symlink)"
            try
                Downloads.download(url, dest; progress = progress_fn)
                localpath = dest
                @info "Fallback download complete: $localpath"
            catch e2
                rethrow(e2)
            end
        else
            rethrow(e)
        end
    end

    url = "https://huggingface.co/datasets/$(repo)/resolve/main/$(filename)"
    dep = DataDep(
        name,
        "Dataset from Hugging Face repository $(repo).",
        url;
        post_fetch_method = p -> isfile(p) ? p : joinpath(p, filename)
    )

    try
        register(dep)
    catch e
        @warn "DataDep registration failed or already registered: $(e)"
    end

    return localpath
end

"""
    load(name::String)

Simple dispatcher that maps known dataset names to repo + filename,
ensures download/registration, and returns local path.
"""
function load(name::String)
    if name == "synthea_1M_3YR"
        repo = "JuliaHealthOrg/JuliaHealthDatasets"
        filename = "synthea_1M_3YR.duckdb"
    else
        throw(ArgumentError("Unknown dataset: $name"))
    end

    return _huggingface_dataset_register(name, repo, filename)
end

export load, _huggingface_dataset_register