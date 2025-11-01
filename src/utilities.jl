"""
    progress_callback(downloaded::Integer, total::Integer, last_pct::Ref{Int})

A utility function to display download progress. It calculates the percentage of
data downloaded and logs the progress in MB and percentage. If the total size is
unknown, it logs the downloaded size in MB.

# Arguments
- `downloaded::Integer`: The number of bytes downloaded so far.
- `total::Integer`: The total number of bytes to be downloaded. If unknown, pass 0.
- `last_pct::Ref{Int}`: A reference to the last logged percentage to avoid redundant logs.

# Returns
- `nothing`
"""
function progress_callback(downloaded::Integer, total::Integer, last_pct::Ref{Int})
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