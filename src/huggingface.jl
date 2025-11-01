using HealthSampleData

const HF = HuggingFaceHub

"""
    _huggingface_dataset_register(name::String, repo::String, filename::String)

Resolve dataset metadata from Hugging Face, download `filename` via HuggingFaceHub,
and return the local filesystem path to the downloaded file. Displays download progress when possible.
"""
function _huggingface_dataset_register(name::String, repo::String, filename::String)
    @info "Resolving Huggingface Metadata for $repo"
    dataset = HF.info(HF.Dataset, repo)

    last_pct = Ref(-1)
    progress_fn = (downloaded, total) -> HealthSampleData.utilities.progress_callback(downloaded, total, last_pct)

    @info "Downloading $filename from $repo via HuggingFaceHub..."
    try
        localpath = HF.file_download(dataset, filename; progress = progress_fn)
        @info "Downloaded to $localpath"
    catch e
        msg = string(e)
        if occursin("symlink", msg) || occursin("creating symlinks", msg) || occursin("Administrator", msg) || occursin("operation not permitted", msg)
            @warn "Symlink creation failed (likely Windows privilege). Falling back to direct HTTP download: $e"
            url = "https://huggingface.co/datasets/$(repo)/resolve/main/$(filename)"
            tmpdir = mktempdir()
            dest = joinpath(tmpdir, filename)
            @info "Downloading $url -> $dest (no symlink)"
            Downloads.download(url, dest; progress = progress_fn)
            localpath = dest
            @info "Fallback download complete: $localpath"
        else
            rethrow(e)
        end
    end

    return localpath
end

export _huggingface_dataset_register