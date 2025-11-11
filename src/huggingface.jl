using Downloads

const HF = HuggingFaceHub

"""
    _huggingface_dataset_register(name::String, repo::String, filename::String)

Resolve dataset metadata from Hugging Face, download `filename` via HuggingFaceHub,
and return the local filesystem path to the downloaded file. Displays download progress when possible.
"""
function _huggingface_dataset_register(name::String, repo::String, filename::String)
    # Ensure full Hugging Face dataset URL
    if !startswith(repo, "http")
        repo = "https://huggingface.co/datasets/$(repo)"
    end

    @info "Resolving Hugging Face metadata for $repo"

    # Try fetching dataset info safely
    dataset = HF.info(HF.Dataset, repo)

    # Set up progress callback
    last_pct = Ref(-1)
    progress_fn = (downloaded, total) -> progress_callback(downloaded, total, last_pct)

    @info "Downloading $filename from $repo via HuggingFaceHub..."
    try
        # Prefer official HuggingFaceHub download if dataset info is available
        if dataset !== nothing
            localpath = HF.file_download(dataset, filename; progress = progress_fn)
        else
            # Direct fallback if HF.info failed
            url = "$repo/resolve/main/$filename"
            tmpdir = mktempdir()
            dest = joinpath(tmpdir, filename)
            @info "Downloading $url -> $dest"
            Downloads.download(url, dest; progress = progress_fn)
            localpath = dest
        end
        @info "Downloaded to $localpath"
        return localpath

    catch e
        msg = string(e)
        if occursin("symlink", msg) || occursin("creating symlinks", msg) ||
           occursin("Administrator", msg) || occursin("operation not permitted", msg)

            @warn "Symlink creation failed (likely Windows privilege issue). Falling back to direct HTTP download: $e"
            url = "$repo/resolve/main/$filename"
            tmpdir = mktempdir()
            dest = joinpath(tmpdir, filename)
            @info "Downloading $url -> $dest (no symlink)"
            Downloads.download(url, dest; progress = progress_fn)
            localpath = dest
            @info "Fallback download complete: $localpath"
            return localpath
        else
            rethrow(e)
        end
    end
end

export _huggingface_dataset_register