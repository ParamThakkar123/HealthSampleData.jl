using HealthSampleData
using Documenter

DocMeta.setdocmeta!(HealthSampleData, :DocTestSetup, :(using HealthSampleData); recursive=true)

makedocs(;
    modules=[HealthSampleData],
    checkdocs = :none,
    authors="TheCedarPrince <jacobszelko@gmail.com>, ParamThakkar123 <paramthakkar864@gmail.com> and contributors",
    repo = "https://github.com/JuliaHealth/HealthSampleData.jl/blob/{commit}{path}#{line}",
    sitename="HealthSampleData.jl",
    format=Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical="https://JuliaHealth.github.io/HealthSampleData.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
    doctest = false,
)

deploydocs(;
    repo="github.com/JuliaHealth/HealthSampleData.jl",
)
