using HealthSampleData
using Documenter

DocMeta.setdocmeta!(HealthSampleData, :DocTestSetup, :(using HealthSampleData); recursive=true)

makedocs(;
    modules=[HealthSampleData],
    authors="TheCedarPrince <jacobszelko@gmail.com> and contributors",
    sitename="HealthSampleData.jl",
    format=Documenter.HTML(;
        canonical="https://TheCedarPrince.github.io/HealthSampleData.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/TheCedarPrince/HealthSampleData.jl",
    devbranch="master",
)
